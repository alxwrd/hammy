extends Control

@onready var message_label: Label = %MessageLabel
@onready var user_label: Label = %UserLabel


func set_message(text: String, user: String):
    message_label.text = text
    user_label.text = user

    var user_colour = Color.from_string("#" + user.sha256_text().substr(0, 6), Color.WEB_GRAY)

    if user_colour.get_luminance() > 0.5:
        user_colour = user_colour.darkened(user_colour.get_luminance() - 0.5)

    user_label.set("theme_override_colors/font_color", user_colour)
    user_label.set("theme_override_colors/font_outline_color", user_colour.darkened(0.5))

    var reading_time = max(text.split(" ").size() * 0.4, 6)

    get_tree().create_timer(reading_time / 2).timeout.connect(
        func callback():
            var tween = create_tween()
            tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), reading_time / 2)
            tween.tween_callback(self.queue_free)
    )
