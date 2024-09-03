extends Node

var player : CharacterBody2D
var p_string : String

@onready var HOLE = preload("res://Scenes/Misc/hole.tscn")
var hole1 = null
var hole2 = null

enum state {LEFT, RIGHT, DOWN, UP}

# Gets player's number string from player
func set_player(_player : CharacterBody2D):
	player = _player
	p_string = player.p_string

# Creates hole and sets up logic for teleporting
func create_hole(hole_state) -> Node2D:
	var offset = Vector2(0, 0)
	
	# Sets proper offset depending on function call
	if hole_state == state.DOWN:
		offset = Vector2(0, 55)
	elif hole_state == state.LEFT:
		offset = Vector2(-55, 0)
	elif hole_state == state.RIGHT:
		offset = Vector2(55, 0)
	
	# Creates hole at player with proper offset
	var hole = HOLE.instantiate()
	hole.global_position = player.global_position
	hole.sprite.global_position += offset
	
	# Ensures the hole is accessible to the mole player
	player.signal_handler.add_child(hole)
	return hole

#
func dig(hole_state) -> void:
	if !hole1:
		hole1 = create_hole(hole_state)
	elif !hole2:
		hole2 = create_hole(hole_state)
		
		hole1.set_exit(hole2)
		hole2.set_exit(hole1)
	else:
		hole1.queue_free()
		hole1 = hole2
		
		hole2 = create_hole(hole_state)
		
		hole1.set_exit(hole2)
		hole2.set_exit(hole1)

func _physics_process(_delta):
	# Prevents code from running if player just died
	if !player:
		return
	
	# When mole user uses their ability in a desired direction, dig hole in that direction
	if Input.is_action_just_pressed(p_string + "ability"):
		if Input.is_action_pressed(p_string + "down"):  # Allows digging holes downwards
			if player.is_on_floor() and !player.rolling:
				dig(state.DOWN)
		elif player.is_on_wall():  # Allows digging holes in walls
			if Input.is_action_pressed(p_string + "left"):
				dig(state.LEFT)
			elif Input.is_action_pressed(p_string + "right"):
				dig(state.RIGHT)
