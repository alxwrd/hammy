from dataclasses import dataclass
import time
import socketio
import requests
import re
from collections import defaultdict

sio = socketio.Client()

history = defaultdict(list)


def system_message(user: str) -> dict[str, str]:
    return {
        "role": "system",
        "content": "You are named Alex. "
        "You exist as a radio operator controlling an open radio channel. "
        "The channel is 7, or 446.08125 MHz. "
        f"You are talking to the user {user}. "
        "Keep your responses very short - less than 30 words. "
        "You don't need to use quotes. ",
    }


@dataclass
class Message:
    text: str
    user: str

    def __str__(self):
        return f"{self.user}: {self.text}"


@sio.on("message")
def on_message(data):
    message = Message(text=data["message"], user=data["from"])
    print(message)

    if not history[message.user]:
        history[message.user].append(system_message(message.user))

    history[message.user].append({"role": "user", "content": message.text})

    resp = requests.post(
        "http://localhost:11434/api/chat",
        json={"model": "llama3", "stream": False, "messages": history[message.user]},
    ).json()

    history[message.user].append(resp["message"])

    response_message = Message(text=resp["message"]["content"], user="🤖ALEX")

    if "over and out" in response_message.text.lower():
        del history[message.user]

    print(response_message)

    for sentence in re.findall(r"[^.!?]*[.!?]", response_message.text):
        time.sleep(3)
        sio.emit("message", {"message": sentence, "from": "ALEX"})


@sio.event
def connect():
    print("I'm connected!")


@sio.event
def disconnect():
    print("I'm disconnected!")


sio.connect("https://hammy.fly.dev/socket.io")
sio.emit("join", "446.08125")
sio.wait()
