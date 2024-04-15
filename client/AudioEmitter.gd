extends Node2D

var sounds = {
    "radio_talk_button_press": preload("res://assets/sounds/buttons/radio_talk_button_press.mp3"),
    "radio_talk_button_release":
    preload("res://assets/sounds/buttons/radio_talk_button_release.mp3"),
    "radio_short_static_click_001":
    preload("res://assets/sounds/static/radio_short_static_click_001.mp3"),
    "radio_short_static_click_002":
    preload("res://assets/sounds/static/radio_short_static_click_002.mp3"),
    "radio_short_static_click_003":
    preload("res://assets/sounds/static/radio_short_static_click_003.mp3"),
    "radio_short_static_click_004":
    preload("res://assets/sounds/static/radio_short_static_click_004.mp3"),
    "radio_short_static_click_005":
    preload("res://assets/sounds/static/radio_short_static_click_005.mp3"),
    "radio_short_static_click_006":
    preload("res://assets/sounds/static/radio_short_static_click_006.mp3"),
    "radio_male_says_1": preload("res://assets/sounds/voice/radio_male_says_1.mp3"),
    "radio_male_says_2": preload("res://assets/sounds/voice/radio_male_says_2.mp3"),
    "radio_male_says_3": preload("res://assets/sounds/voice/radio_male_says_3.mp3"),
    "radio_male_says_4": preload("res://assets/sounds/voice/radio_male_says_4.mp3"),
    "radio_male_says_5": preload("res://assets/sounds/voice/radio_male_says_5.mp3"),
    "radio_male_says_6": preload("res://assets/sounds/voice/radio_male_says_6.mp3"),
    "radio_male_says_7": preload("res://assets/sounds/voice/radio_male_says_7.mp3"),
    "radio_male_says_8": preload("res://assets/sounds/voice/radio_male_says_8.mp3"),
    "radio_male_says_9": preload("res://assets/sounds/voice/radio_male_says_9.mp3"),
    "radio_male_says_10": preload("res://assets/sounds/voice/radio_male_says_10.mp3"),
    "radio_lost_signal_clicks": preload("res://assets/sounds/static/radio_lost_signal_clicks.mp3"),
    "radio_beeps_button_positive":
    preload("res://assets/sounds/beeps/radio_beeps_button_positive.mp3"),
    "radio_wheel_click_001": preload("res://assets/sounds/buttons/radio_wheel_click_001.mp3"),
    "radio_wheel_click_002": preload("res://assets/sounds/buttons/radio_wheel_click_002.mp3"),
    "radio_wheel_click_003": preload("res://assets/sounds/buttons/radio_wheel_click_003.mp3"),
}

var last_message_received_sound: int = -1

var channels: Array[AudioStreamPlayer2D] = []


func _ready():
    for child in get_children():
        if child is AudioStreamPlayer2D:
            channels.append(child)


func play_sound(sound):
    if sound is Array:
        sound = sound[randi() % sound.size()]

    _play_sound(sounds[sound])


func _play_sound(sound: AudioStream):
    for channel in channels:
        if channel.playing:
            continue
        channel.stream = sound
        channel.play()
        return

    print("No available channels to play sound")


func _input(event):
    if event is InputEventKey and event.keycode == KEY_ENTER and not event.echo and event.pressed:
        play_sound("radio_talk_button_press")


func message_received():
    var message_sounds = [
        "radio_short_static_click_001",
        "radio_short_static_click_002",
        "radio_short_static_click_003",
        "radio_short_static_click_004",
        "radio_short_static_click_005",
        "radio_short_static_click_006"
    ]

    var sound_choice = randi() % message_sounds.size()

    while sound_choice == last_message_received_sound:
        sound_choice = randi() % message_sounds.size()

    last_message_received_sound = sound_choice

    play_sound(message_sounds[sound_choice])


func message_sent(_message):
    play_sound("radio_talk_button_release")
