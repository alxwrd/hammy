extends Node2D

signal state_changed(state: String)

@onready var state = "on"
@onready var is_mouse_over = false


func get_size():
    return $Sprite2D.get_rect().size * $Sprite2D.get_scale()


func _on_mouse_entered():
    Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
    is_mouse_over = true


func _on_mouse_exited():
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    is_mouse_over = false


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
            state = "on" if state == "off" else "off"
            emit_signal("state_changed", state)
            AudioEmitter.play_sound("radio_wheel_click_002")
            if state == "on":
                get_tree().create_timer(0.1).timeout.connect(
                    func callback(): AudioEmitter.play_sound("radio_short_static_click_004")
                )
