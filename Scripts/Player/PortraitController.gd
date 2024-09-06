extends Control

@export var signal_handler : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	signal_handler.connect("alter_portrait", alter_portrait)
	signal_handler.connect("change_dodge_icon", change_dodge_icon)

# Alters Player's portrait depending on actions
func alter_portrait(p_string : String, face_string : String):
	var texture = load("res://Sprites/Portrait/Faces/" + face_string.capitalize() + ".png")
	find_child(p_string + "Portrait").alter(texture)

# Alters Player's dodge icon's visibility
func change_dodge_icon(p_string : String, state : bool):
	find_child(p_string + "Portrait").change_dodge_icon(state)
