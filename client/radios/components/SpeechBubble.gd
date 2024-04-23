extends Node2D

@export var message: String = "Test message"
@export var duration: float = 6

@onready var label = $Label


func _ready():
    label.text = message
    get_tree().create_timer(duration / 2).timeout.connect(
        func callback():
            var tween = create_tween()
            tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), duration / 2)
            tween.tween_callback(self.queue_free)
    )
