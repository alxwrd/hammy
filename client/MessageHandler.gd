extends Node2D

signal on_message_handler_ready
signal on_disconnect
signal on_channel_changed(channel: String)
signal on_message_delivered(message: String)
signal on_message_received(message: String)

enum State { CONNECTING, CONNECTED, DISCONNECTED }

@export var socket_io_server: String = "https://hammy.fly.dev/socket.io"

var state = State.DISCONNECTED
var client: SocketIOClient

@onready var connection_ping: Timer = $ConnectionPing


func _ready():
    establish_connection()
    $ConnectionPing.timeout.connect(_on_connection_ping_timeout)


func send_message(message: String):
    # TODO: Implement message buffer
    print("[sending] event:message, data:'%s'" % message)
    client.socketio_send("message", message)
    on_message_delivered.emit(message)


func change_channel(channel: String):
    print("[sending] event:channel, data:'%s'" % channel)
    client.socketio_send("join", channel)
    on_channel_changed.emit(channel)


func establish_connection():
    state = State.CONNECTING
    client = SocketIOClient.new(socket_io_server)

    client.on_connect.connect(_on_socket_connect)
    client.on_disconnect.connect(_on_socket_disconnect)
    client.on_event.connect(_on_socket_event)

    add_child(client)


func _on_connection_ping_timeout():
    if client.get_state() == WebSocketPeer.STATE_CLOSED:
        remove_child(client)
        print("Connection lost, reconnecting...")
        establish_connection()

    connection_ping.start()


func _exit_tree():
    client.socketio_disconnect()


func _on_socket_connect(_payload: Variant, _name_space, error: bool):
    if error:
        push_error("Failed to connect to backend!")
    else:
        print("[connect] connection established")
    state = State.CONNECTED
    on_message_handler_ready.emit()


func _on_socket_disconnect(_namespace: String):
    state = State.DISCONNECTED
    print("[disconnect] lost connection")


func _on_socket_event(event: String, payload: Variant, _name_space):
    print("[receiving] event:%s, data:'%s'" % [event, payload])

    if event == "message":
        on_message_received.emit(payload)
