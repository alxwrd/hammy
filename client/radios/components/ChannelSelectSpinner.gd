extends Node2D

@export var channels: Array = [
    "446.00625",
    "446.01875",
    "446.03125",
    "446.04375",
    "446.05625",
    "446.06875",
    "446.08125",
    "446.09375",
]

@onready var is_mouse_over = false
@onready var selected_channel = 0
@onready var sprite = $Sprite2D


func _ready():
    EventBus.message_handler_ready.connect(func(): change_channel(selected_channel, false))
    update_configuration_warnings()


func change_channel(channel: int, play_sound: bool = true):
    if channel < 0 or channel >= channels.size():
        return
    selected_channel = channel
    $Sprite2D.rotation_degrees = -(channel * 44.5)
    EventBus.channel_change.emit(channels[selected_channel])

    if play_sound:
        (
            AudioEmitter
            . play_sound(
                [
                    "radio_wheel_click_001",
                    "radio_wheel_click_003",
                ]
            )
        )


func _input(event):
    if event is InputEventMouseButton and is_mouse_over:
        if event.is_pressed():
            if (
                event.button_index == MOUSE_BUTTON_WHEEL_UP
                or event.button_index == MOUSE_BUTTON_LEFT
            ):
                change_channel(selected_channel + 1)
            if (
                event.button_index == MOUSE_BUTTON_WHEEL_DOWN
                or event.button_index == MOUSE_BUTTON_RIGHT
            ):
                change_channel(selected_channel - 1)


func _on_mouse_entered():
    Input.set_default_cursor_shape(Input.CURSOR_VSIZE)
    is_mouse_over = true


func _on_mouse_exited():
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    is_mouse_over = false
