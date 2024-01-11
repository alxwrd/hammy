extends Node2D

var client: SocketIOClient


@onready var connection_ping: Timer = $ConnectionPing



func _ready():
    establish_connection()

    $ConnectionPing.timeout.connect(_on_connection_ping_timeout)

    EventBus.message_send.connect(_on_message_send)
    EventBus.channel_change.connect(_on_channel_change)
    EventBus.chirp_send.connect(_on_chirp_send)


func _on_message_send(message):
    print("[sending] event:message, data:'%s'" % message)
    client.socketio_send("message", message)
    EventBus.message_send_complete.emit(message)


func _on_channel_change(channel):
    print("[sending] event:channel, data:'%s'" % channel)
    client.socketio_send("join", channel)
    EventBus.channel_change_complete.emit(channel)


func _on_chirp_send():
    print("[sending] event:chirp")
    client.socketio_send("chirp")
    EventBus.chirp_send_complete.emit()


func establish_connection():
    client = SocketIOClient.new("http://localhost:8000/socket.io")

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
    EventBus.message_handler_ready.emit()


func _on_socket_disconnect(_namespace: String):
    print("[disconnect] lost connection")


func _on_socket_event(event: String, payload: Variant, _name_space):
    print("[receiving] event:%s, data:'%s'" % [event, payload])

    if event == "message":
        EventBus.message_received.emit(payload)

    if event == "chirp":
        EventBus.chirp_received.emit(payload)
