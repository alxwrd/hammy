extends Node2D

signal state_changed(state: String)

@onready var state = "ON"
@onready var is_mouse_over = false
@onready var starting_position = get_position()


func get_size():
    return $Sprite2D.get_rect().size * $Sprite2D.get_scale()


func on():
    state = "ON"
    position = starting_position


func off():
    state = "OFF"
    position = starting_position + Vector2(18, 0)


func _on_mouse_entered():
    Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
    is_mouse_over = true


func _on_mouse_exited():
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    is_mouse_over = false


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
            state_changed.emit("ON" if state == "OFF" else "OFF")

            AudioEmitter.play_sound("radio_wheel_click_002")
            if state == "ON":
                get_tree().create_timer(0.1).timeout.connect(
                    func callback(): AudioEmitter.play_sound("radio_short_static_click_004")
                )
