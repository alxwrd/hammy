extends Node2D

var button_press: AudioStream = preload("res://assets/sounds/buttons/radio_talk_button_press.mp3")
var button_release: AudioStream = preload(
    "res://assets/sounds/buttons/radio_talk_button_release.mp3"
)

var last_message_received_sound: int = -1
var message_received: Array[AudioStream] = [
    preload("res://assets/sounds/static/radio_short_static_click_001.mp3"),
    preload("res://assets/sounds/static/radio_short_static_click_002.mp3"),
    preload("res://assets/sounds/static/radio_short_static_click_003.mp3"),
    preload("res://assets/sounds/static/radio_short_static_click_004.mp3"),
    preload("res://assets/sounds/static/radio_short_static_click_005.mp3"),
    preload("res://assets/sounds/static/radio_short_static_click_006.mp3"),
]

var counting = {
    "one": preload("res://assets/sounds/voice/radio_male_says_1.mp3"),
    "two": preload("res://assets/sounds/voice/radio_male_says_2.mp3"),
    "three": preload("res://assets/sounds/voice/radio_male_says_3.mp3"),
    "four": preload("res://assets/sounds/voice/radio_male_says_4.mp3"),
    "five": preload("res://assets/sounds/voice/radio_male_says_5.mp3"),
    "six": preload("res://assets/sounds/voice/radio_male_says_6.mp3"),
    "sever": preload("res://assets/sounds/voice/radio_male_says_7.mp3"),
    "eight": preload("res://assets/sounds/voice/radio_male_says_8.mp3"),
    "nine": preload("res://assets/sounds/voice/radio_male_says_9.mp3"),
    "ten": preload("res://assets/sounds/voice/radio_male_says_10.mp3"),
}

var empty_response: AudioStream = preload("res://assets/sounds/static/radio_lost_signal_clicks.mp3")
var not_empty_response: AudioStream = preload(
    "res://assets/sounds/beeps/radio_beeps_button_positive.mp3"
)

@onready var channel1: AudioStreamPlayer2D = $Channel1
@onready var channel2: AudioStreamPlayer2D = $Channel2


func _ready():
    EventBus.message_received.connect(_on_message_received)
    EventBus.message_send.connect(_on_message_sent)
    EventBus.chirp_received.connect(_on_chirp_received)


func play_sound(sound: AudioStream):
    for channel in [$Channel1, $Channel2]:
        if channel.playing:
            continue
        channel.stream = sound
        channel.play()
        return

    print("No available channels to play sound")


func _input(event):
    if event is InputEventKey and event.keycode == KEY_ENTER and not event.echo and event.pressed:
        play_sound(button_press)


func _on_message_received(message):
    var sound_choice = randi() % message_received.size()

    while sound_choice == last_message_received_sound:
        sound_choice = randi() % message_received.size()

    last_message_received_sound = sound_choice

    play_sound(message_received[sound_choice])

    if message in counting:
        play_sound(counting[message])


func _on_message_sent(_message):
    play_sound(button_release)


func _on_chirp_received(chirp):
    if chirp == "EMPTY":
        play_sound(empty_response)

    if chirp == "NOT_EMPTY":
        play_sound(not_empty_response)
