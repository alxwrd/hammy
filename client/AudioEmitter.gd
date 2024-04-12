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

@onready var channel1: AudioStreamPlayer2D = $Channel1
@onready var channel2: AudioStreamPlayer2D = $Channel2


func _ready():
    EventBus.message_received.connect(_on_message_received)
    EventBus.message_send.connect(_on_message_sent)
    EventBus.chirp_received.connect(_on_chirp_received)


func play_sound(sound):
    if sound is Array:
        sound = sound[randi() % sound.size()]

    _play_sound(sounds[sound])


func _play_sound(sound: AudioStream):
    for channel in [$Channel1, $Channel2]:
        if channel.playing:
            continue
        channel.stream = sound
        channel.play()
        return

    print("No available channels to play sound")


func _input(event):
    if event is InputEventKey and event.keycode == KEY_ENTER and not event.echo and event.pressed:
        play_sound("radio_talk_button_press")


func _on_message_received(_message):
    var message_received = [
        "radio_short_static_click_001",
        "radio_short_static_click_002",
        "radio_short_static_click_003",
        "radio_short_static_click_004",
        "radio_short_static_click_005",
        "radio_short_static_click_006"
    ]

    var sound_choice = randi() % message_received.size()

    while sound_choice == last_message_received_sound:
        sound_choice = randi() % message_received.size()

    last_message_received_sound = sound_choice

    play_sound(message_received[sound_choice])


func _on_message_sent(_message):
    play_sound("radio_talk_button_release")


func _on_chirp_received(chirp):
    if chirp == "EMPTY":
        play_sound("radio_lost_signal_clicks")

    if chirp == "NOT_EMPTY":
        play_sound("radio_beeps_button_positive")
