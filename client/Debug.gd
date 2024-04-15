extends Node2D

signal on_message_send(message: String)

@onready var text = $TextEdit


func _on_text_edit_gui_input(event: InputEvent):
    if event is InputEventKey and event.keycode == KEY_ENTER:
        get_viewport().set_input_as_handled()

        if not event.pressed:
            on_message_send.emit(text.text)
            text.text = ""
