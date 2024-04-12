extends Node2D


@onready var label = $Label


func _ready():
    visible = false
    EventBus.message_received.connect(
        func(message):
            label.text = message
            visible = true
            get_tree().create_timer(4).timeout.connect(
                    func callback(): visible = false
                )
    )
