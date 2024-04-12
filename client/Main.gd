extends Node2D

var client = SocketIOClient
var dragging = false
var mouse_start = Vector2()

var pointer_cursor = preload("res://assets/sprites/cursors/pointer.png")
var rotate_cursor = preload("res://assets/sprites/cursors/rotate.png")
var hand_cursor = preload("res://assets/sprites/cursors/hand.png")

@onready var radio = $Radio


func _ready():
    get_viewport().transparent_bg = true
    DisplayServer.window_set_size(radio.get_size())
    DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)

    Input.set_custom_mouse_cursor(pointer_cursor, Input.CURSOR_ARROW, Vector2(6, 2))
    Input.set_custom_mouse_cursor(rotate_cursor, Input.CURSOR_VSIZE, Vector2(6, 2))
    Input.set_custom_mouse_cursor(hand_cursor, Input.CURSOR_POINTING_HAND, Vector2(6, 2))


func _process(_delta):
    dragging = true if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else false


func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        mouse_start = get_viewport().get_mouse_position()

    if event is InputEventMouseMotion and dragging:
        DisplayServer.window_set_position(
            (
                Vector2(get_tree().get_root().position)
                + get_viewport().get_mouse_position()
                - mouse_start
            )
        )
