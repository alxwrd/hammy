
import asyncio
import socketio


server = socketio.AsyncServer(async_mode='asgi')
app = socketio.ASGIApp(server)


async def current_room(sid):
    rooms = server.rooms(sid)
    rooms.remove(sid)

    try:
        return rooms.pop()
    except IndexError:
        return await join(sid, "144.0")

@server.event
async def connect(sid, environ, auth):
    print(f"[connect] from:{sid}@{environ['REMOTE_ADDR']}")


@server.event
async def disconnect(sid):
    print(f"[disconnect] from:{sid} - bye bye!")


@server.event
async def message(sid, data):
    room = await current_room(sid)
    print(f"[message] from:{sid}, data:'{data}', room:{room}")
    await server.emit("message", data, room=room, skip_sid=sid)


@server.event
async def join(sid, data):
    print(f"[join] {sid} entered '{data}'")

    current_rooms = server.rooms(sid)

    for room in current_rooms:
        if room != sid:
            await server.leave_room(sid, room)

    await server.enter_room(sid, data)


@server.event
async def chirp(sid):
    print(f"[chirp] from:{sid}, rooms:{server.rooms(sid)}")

    room = await current_room(sid)

    room_particpants = server.manager.get_participants("/", room)

    await asyncio.sleep(1)

    for particpant in room_particpants:
        if particpant[0] != sid:
            return await server.emit("chirp", "NOT_EMPTY", to=sid)

    return await server.emit("chirp", "EMPTY", to=sid)
