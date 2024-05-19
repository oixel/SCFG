extends Node2D

@export var player : CharacterBody2D
@onready var p_string = "P" + str(player.player_number) + "_"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#
	# VERY ROUGH TEST FOR AIMING
	#
	if Input.is_action_pressed(p_string + "aim_right"):
		rotation += 0.05
		if rotation > 360:
			rotation = 0
	
	if Input.is_action_pressed(p_string + "aim_left"):
		rotation -= 0.05
		if rotation < -360:
			rotation = 0
	#
	#
	#
