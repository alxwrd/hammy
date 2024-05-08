extends Node2D

var allowed_characters = "[A-Za-z0-9-]"

var username: String:
    get:
        return input.text if input.text else "ANON"
    set(value):
        input.text = value

@onready var input: LineEdit = %Input


func _ready():
    var file = FileAccess.open("user://username", FileAccess.READ)
    if file:
        username = file.get_as_text()


func _on_input_text_changed(new_text: String):
    var old_caret_position = input.caret_column

    var word = ""
    var regex = RegEx.new()
    regex.compile(allowed_characters)

    for valid_character in regex.search_all(new_text):
        word += valid_character.get_string()

    input.text = word.to_upper()

    input.caret_column = old_caret_position

    var file = FileAccess.open("user://username", FileAccess.WRITE)
    file.store_string(input.text)
