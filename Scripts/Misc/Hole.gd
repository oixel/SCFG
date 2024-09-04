extends Node2D

@export var area : Area2D
@export var out : Node2D
@export var sprite : Sprite2D

# Set in mole script;
var exit_point

# Called in mole script to set exit point
func set_exit(exit):
	exit_point = exit

# Moves object passed in to out point
func teleport(obj):
	obj.global_position = out.global_position

# Checks every frame if a player is trying to use hole
func _physics_process(_delta):
	# Only allows players to use hole if not attempting to parry and not currently rolling
	if exit_point:
		if area.get_overlapping_bodies():
			for obj in area.get_overlapping_bodies():
				if obj.is_in_group("Player"):
					if !obj.rolling and !obj.crouched:
						if Input.is_action_just_pressed("%s_roll" % obj.control_type):
							exit_point.teleport(obj)

# Prevents player from rolling while on the enterance of a hole
func _on_area_2d_body_entered(target):
	if target.is_in_group("Player"):
		target.can_roll = false

# Allows player to roll again after exiting hole enterance
func _on_area_2d_body_exited(target):
	if target.is_in_group("Player"):
		target.can_roll = true
