extends Node2D

@export var area : Area2D
@export var out : Node2D

# Set in mole script;
var exit_point

# Called in mole script to set exit point
func set_exit(exit):
	exit_point = exit

# Moves object passed in to out point
func teleport(obj):
	obj.global_position.x = out.global_position.x
	obj.global_position.y = out.global_position.y
	print(str(obj.global_position.y) + " :: Player")
	print(str(exit_point.out.global_position.y) + " :: Exit")
	print(str(out.global_position.y) + " :: Enter")
	print()

# Checks every frame if a player is trying to use hole
func _physics_process(_delta):
	if exit_point:
		if area.get_overlapping_bodies():
			for obj in area.get_overlapping_bodies():
				if obj.is_in_group("Player"):
					if Input.is_action_just_pressed(obj.p_string + "down"):
						exit_point.teleport(obj)
