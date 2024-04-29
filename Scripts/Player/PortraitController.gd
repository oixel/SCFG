extends Control

@export var signal_handler : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	signal_handler.connect("alter_portrait", alter_portrait)

# Alters Player's portrait depending on actions
func alter_portrait(p_string : String, face_string : String):
	var texture = load("res://Sprites/Portrait/Faces/" + face_string.capitalize() + ".png")
	find_child(p_string + "Portrait").alter(texture)
