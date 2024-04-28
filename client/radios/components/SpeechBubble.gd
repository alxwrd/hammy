extends Control

@export var message: String = "Test message"

@onready var label: Label = %Label

func _ready():
    label.text = message


func set_message(text: String):
    label.text = text

    var reading_time = max(text.split(" ").size() * 0.4, 6)

    get_tree().create_timer(reading_time / 2).timeout.connect(
        func callback():
            var tween = create_tween()
            tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), reading_time / 2)
            tween.tween_callback(self.queue_free)
    )
