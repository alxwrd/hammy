extends Node2D

@export var default_channel = "144.0"

var _current_channel = default_channel

@onready var sprite = $Sprite
@onready var on_off_switch = $OnOffSwitch
@onready var power_indicator = $PowerIndicator


func get_size():
    return sprite.get_rect().size * sprite.get_scale()


func current_channel():
    return _current_channel


func _on_on_off_switch_state_changed(state: String):
    if state == "on":
        power_indicator.on()
        on_off_switch.position = Vector2(126, 400)
    if state == "off":
        power_indicator.off()
        on_off_switch.position = Vector2(144, 400)
