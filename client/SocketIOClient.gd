# MIT License

# Copyright (c) 2023 teamclouday

# https://github.com/teamclouday/GodotSocketIO

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class_name SocketIOClient extends Node

enum EngineIOPacketType {
    open = 0,
    close = 1,
    ping = 2,
    pong = 3,
    message = 4,
    upgrade = 5,
    noop = 6,
}

enum SocketIOPacketType {
    CONNECT = 0,
    DISCONNECT = 1,
    EVENT = 2,
    ACK = 3,
    CONNECT_ERROR = 4,
    BINARY_EVENT = 5,
    BINARY_ACK = 6,
}

var _url: String
var _client: WebSocketPeer = WebSocketPeer.new()
var _sid: String
var _pingTimeout: int = 0
var _pingInterval: int = 0
var _connected: bool = false

# triggered when engine.io connection is established
signal on_engine_connected(sid: String)
# triggered when engine.io connection is closed
signal on_engine_disconnected(code: int, reason: String)
# triggered when engine.io message is received
signal on_engine_message(payload: String)

# triggered when socket.io connection is established
signal on_connect(payload: Variant, name_space: String, error: bool)
# triggered when socket.io connection is closed
signal on_disconnect(name_space: String)
# triggered when socket.io event is received
signal on_event(event_name: String, payload: Variant, name_space: String)


func _init(url: String):
    url = _preprocess_url(url)
    _url = "%s?EIO=4&transport=websocket" % url


func _preprocess_url(url: String) -> String:
    if not url.ends_with("/"):
        url = url + "/"
    if url.begins_with("https"):
        url = "wss" + url.erase(0, len("https"))
    elif url.begins_with("http"):
        url = "ws" + url.erase(0, len("http"))
    return url


func _ready():
    _client.connect_to_url(_url)


func _process(_delta):
    _client.poll()

    var state = _client.get_ready_state()
    if state == WebSocketPeer.STATE_OPEN:
        while _client.get_available_packet_count():
            var packet = _client.get_packet()
            var packetString = packet.get_string_from_utf8()
            if len(packetString) > 0:
                _engineio_decode_packet(packetString)
            # TODO: handle binary data?

    elif state == WebSocketPeer.STATE_CLOSED:
        var code = _client.get_close_code()
        var reason = _client.get_close_reason()
        on_engine_disconnected.emit(code, reason)
        _connected = false
        set_process(false)


func _exit_tree():
    if _client.get_ready_state() == WebSocketPeer.STATE_OPEN:
        _engineio_send_packet(EngineIOPacketType.close)
    _client.close()


func get_state():
    _client.poll()
    return _client.get_ready_state()


func _engineio_decode_packet(packet: String):
    var packetType = int(packet.substr(0, 1))
    var packetPayload = packet.substr(1)

    match packetType:
        EngineIOPacketType.open:
            var json = JSON.new()
            json.parse(packetPayload)
            _sid = json.data["sid"]
            _pingTimeout = int(json.data["pingTimeout"])
            _pingInterval = int(json.data["pingInterval"])
            on_engine_connected.emit(_sid)
            _connected = true
            socketio_connect()

        EngineIOPacketType.ping:
            _engineio_send_packet(EngineIOPacketType.pong)

        EngineIOPacketType.message:
            _socketio_parse_packet(packetPayload)
            on_engine_message.emit(packetPayload)


func _engineio_send_packet(type: EngineIOPacketType, payload: String = ""):
    if len(payload) == 0:
        _client.send_text("%d" % type)
    else:
        _client.send_text("%d%s" % [type, payload])


func _socketio_parse_packet(payload: String):
    var packetType = int(payload.substr(0, 1))
    payload = payload.substr(1)

    var regex = RegEx.new()
    regex.compile("(\\d+)-")
    var regexMatch = regex.search(payload)
    if regexMatch and regexMatch.get_start() == 0:
        payload = payload.substr(regexMatch.get_end())
        push_error("Binary data payload not supported!")

    var name_space = "/"
    regex.compile("(\\w),")
    regexMatch = regex.search(payload)
    if regexMatch and regexMatch.get_start() == 0:
        payload = payload.substr(regexMatch.get_end())
        name_space = regexMatch.get_string(1)

    # var ack_id = null
    regex.compile("(\\d+)")
    regexMatch = regex.search(payload)
    if regexMatch and regexMatch.get_start() == 0:
        payload = payload.substr(regexMatch.get_end())
        push_warning("Ignoring acknowledge ID!")

    var data = null
    if len(payload) > 0:
        var json = JSON.new()
        if json.parse(payload) == OK:
            data = json.data

    match packetType:
        SocketIOPacketType.CONNECT:
            on_connect.emit(data, name_space, false)
        SocketIOPacketType.CONNECT_ERROR:
            on_connect.emit(data, name_space, true)
        SocketIOPacketType.EVENT:
            if typeof(data) != TYPE_ARRAY:
                push_error("Invalid socketio event format!")
            var eventName = data[0]
            var eventData = data[1] if len(data) > 1 else null
            on_event.emit(eventName, eventData, name_space)


func _socketio_send_packet(
    type: SocketIOPacketType,
    name_space: String,
    data: Variant = null,
    binaryData: Array[PackedByteArray] = [],
    ack_id: Variant = null
):
    var payload = "%d" % type
    if binaryData.size() > 0:
        payload += "%d-" % binaryData.size()
    if name_space != "/":
        payload += "%s," % name_space
    if ack_id != null:
        payload += "%d" % ack_id
    if data != null:
        payload += "%s" % JSON.stringify(data)

    _engineio_send_packet(EngineIOPacketType.message, payload)

    for binary in binaryData:
        _client.put_packet(binary)


# connect to socket.io server by namespace
func socketio_connect(name_space: String = "/"):
    _socketio_send_packet(SocketIOPacketType.CONNECT, name_space)


# disconnect from socket.io server by namespace
func socketio_disconnect(name_space: String = "/"):
    _socketio_send_packet(SocketIOPacketType.DISCONNECT, name_space)
    on_disconnect.emit(name_space)


# send event to socket.io server by namespace
func socketio_send(event_name: String, payload: Variant = null, name_space: String = "/"):
    if _client.get_ready_state() != WebSocketPeer.STATE_OPEN:
        return

    if payload == null:
        _socketio_send_packet(SocketIOPacketType.EVENT, name_space, [event_name])
    else:
        _socketio_send_packet(SocketIOPacketType.EVENT, name_space, [event_name, payload])
