extends Node2D

@onready var text = $TextEdit
@onready var chirp_button = $Button
@onready var label = $Label


func _ready():
    EventBus.message_received.connect(
        func(message):
            $Label.text = message
            $Label/Timer.start()
            $Label/Timer.timeout.connect(
                func():
                    $Label.text = ""
            )
    )

    $GridContainer/Button1.pressed.connect(
        func():
            EventBus.channel_change.emit("144.0")
    )
    $GridContainer/Button2.pressed.connect(
        func():
            EventBus.channel_change.emit("144.1")
    )
    $GridContainer/Button3.pressed.connect(
        func():
            EventBus.channel_change.emit("144.2")
    )
    $GridContainer/Button4.pressed.connect(
        func():
            EventBus.channel_change.emit("144.3")
    )
    $GridContainer/Button5.pressed.connect(
        func():
            EventBus.channel_change.emit("144.4")
    )
    $GridContainer/Button6.pressed.connect(
        func():
            EventBus.channel_change.emit("144.5")
    )
    $GridContainer/Button7.pressed.connect(
        func():
            EventBus.channel_change.emit("144.7")
    )
    $GridContainer/Button8.pressed.connect(
        func():
            EventBus.channel_change.emit("144.8")
    )
    $GridContainer/Button9.pressed.connect(
        func():
            EventBus.channel_change.emit("144.9")
    )

func _input(event):
    if event is InputEventKey and event.keycode == KEY_ENTER:
        get_viewport().set_input_as_handled()

        if not event.pressed:
            EventBus.message_send.emit(text.text)
            text.text = ""


func _on_button_pressed():
    EventBus.chirp_send.emit()
    chirp_button.disabled = true
    EventBus.chirp_received.connect(
        func(_chirp):
            chirp_button.disabled = false
    )
