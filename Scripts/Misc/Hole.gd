extends Node2D

@export var area : Area2D
@export var out : Marker2D

# Set in mole script;
var exit_point

# Keep an array of things just passed through to prevent infinite teleporting

# Called in mole script to set exit point
func set_exit(exit):
	exit_point = exit

# 
func teleport(obj):
	obj.global_position = out.global_position

func _on_area_2d_body_entered(obj):
	if exit_point:
		exit_point.teleport(obj)
