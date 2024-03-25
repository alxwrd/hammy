extends Node2D

@onready var sprite = $Sprite

@export var default_channel = "144.0"
var _current_channel = default_channel


func _ready():
    EventBus.message_handler_ready.connect(func(): EventBus.channel_change.emit(current_channel()))


func get_size():
    return sprite.get_rect().size * sprite.get_scale()


func current_channel():
    return _current_channel
