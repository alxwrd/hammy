extends Node2D

@onready var text = $TextEdit
@onready var chirp_button = $Button


func _input(event):
    if event is InputEventKey and event.keycode == KEY_ENTER:
        get_viewport().set_input_as_handled()

        if not event.pressed:
            EventBus.message_send.emit(text.text)
            text.text = ""


func _on_button_pressed():
    EventBus.chirp_send.emit()
    chirp_button.disabled = true
    EventBus.chirp_received.connect(func(_chirp): chirp_button.disabled = false)
