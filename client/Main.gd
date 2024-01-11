extends Node2D

var client = SocketIOClient

@onready var radio = $Radio

var dragging = false
var mouse_start = Vector2()

func _ready():
    get_viewport().transparent_bg = true
    DisplayServer.window_set_size(radio.get_size())
    DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)


func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            dragging = true
            mouse_start = get_viewport().get_mouse_position()

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
            dragging = false

    if event is InputEventMouseMotion and dragging:
        DisplayServer.window_set_position(
            Vector2(get_tree().get_root().position) + get_viewport().get_mouse_position() - mouse_start
        )
