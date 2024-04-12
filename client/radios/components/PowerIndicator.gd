extends Node2D

@onready var light_on = $LightOn


func on():
    light_on.visible = true


func off():
    light_on.visible = false
