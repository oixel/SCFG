extends Node2D

@export var area : Area2D
@export var out : Marker2D

# Set in mole script;
var exit_point

# Keep an array of things just passed through to prevent infinite teleporting
var need_to_exit := []

# Called in mole script to set exit point
func set_exit(exit):
	exit_point = exit

# Moves object passed in to out point
func teleport(obj):
	need_to_exit.append(obj)
	obj.global_position = out.global_position

# Checks every frame if a player is trying to use hole
func _physics_process(_delta):
	if exit_point:
		if area.get_overlapping_bodies():
			for obj in area.get_overlapping_bodies():
				if obj.is_in_group("Player"):
					if Input.is_action_just_pressed(obj.p_string + "down"):
						exit_point.teleport(obj)
