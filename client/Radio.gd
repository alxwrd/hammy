extends Node2D

enum PowerState { ON, OFF }

@export var speech_spawn_point: Marker2D
@export var default_channel = "144.0"
@export var power_state: PowerState = PowerState.ON:
    get:
        return power_state
    set(value):
        power_state = value
        if not is_inside_tree():
            return
        match value:
            PowerState.ON:
                on_off_switch.on()
                power_indicator.on()
            PowerState.OFF:
                on_off_switch.off()
                power_indicator.off()

@onready var sprite = $Sprite
@onready var on_off_switch = $OnOffSwitch
@onready var power_indicator = $PowerIndicator
@onready var message_handler = $MessageHandler
@onready var message_container = %MessageContainer
@onready var user = %UserName
@onready var speech_bubble = preload("res://radios/components/SpeechBubble.tscn")


func _ready():
    DisplayServer.window_set_mouse_passthrough(%ClickableArea.polygon)


func _on_message_send(message):
    if power_state == PowerState.OFF:
        return

    message_handler.send_message(message, user.username)
    AudioEmitter.play_sound("radio_talk_button_release")


func _on_message_received(message):
    if power_state == PowerState.OFF:
        return

    var bubble = speech_bubble.instantiate()
    message_container.add_child(bubble)
    bubble.set_message(message.message, message.from)

    AudioEmitter.message_received()


func _on_channel_changed(channel: String):
    if not message_handler or message_handler.state != message_handler.State.CONNECTED:
        return get_tree().create_timer(1.0).timeout.connect(
            func retry(): _on_channel_changed(channel)
        )
    message_handler.change_channel(channel)


func get_size():
    return sprite.get_rect().size * sprite.get_scale()


func _on_on_off_switch_state_changed(state: String):
    power_state = PowerState.get(state)
