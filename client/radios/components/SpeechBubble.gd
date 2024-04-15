extends Node2D

@onready var label = $Label


func display_message(message: String):
    visible = true
    label.text = message
    visible = true
    get_tree().create_timer(4).timeout.connect(func callback(): visible = false)
