extends Node

var player : CharacterBody2D
var control_type : String

@onready var HOLE = preload("res://Scenes/Misc/hole.tscn")
var hole1 = null
var hole2 = null

# Gets player's number string from player
func set_player(_player : CharacterBody2D):
	player = _player
	control_type = player.control_type

# Creates hole and sets up logic for teleporting
func create_hole(hole_state) -> Node2D:
	var offset = Vector2(0, 0)
	
	# Sets proper offset depending on function call
	if hole_state == "down":
		offset = Vector2(0, 55)
	elif hole_state == "left":
		offset = Vector2(-55, 0)
	elif hole_state == "right":
		offset = Vector2(55, 0)
	
	# Creates hole at player with proper offset
	var hole = HOLE.instantiate()
	hole.global_position = player.global_position
	hole.sprite.global_position += offset
	
	# Sets the key dependent on what position it was created in
	hole.set_key(hole_state)
	
	# Ensures the hole is accessible to the mole player
	player.signal_handler.add_child(hole)
	return hole

# Creates / deletes holes and fills out the exit functionality depending on hole count
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
	if Input.is_action_just_pressed("%s_ability" % control_type):
		if Input.is_action_pressed("%s_down" % control_type):  # Allows digging holes downwards
			if player.is_on_floor() and !player.rolling:
				dig("down")
		elif player.is_on_wall():  # Allows digging holes in walls
			if Input.is_action_pressed("%s_left" % control_type):
				dig("left")
			elif Input.is_action_pressed("%s_right" % control_type):
				dig("right")
