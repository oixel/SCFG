extends Node2D

@export var area : Area2D
@export var out : Node2D
@export var sprite : Sprite2D
var key : String

# Set in mole script;
var exit_point

# Called in mole script to set exit point
func set_exit(exit):
	exit_point = exit

# Called in mole script and sets the key required to be pressed to go through the hole
func set_key(_key):
	key = _key

# Moves object passed in to out point
func teleport(obj):
	obj.global_position = out.global_position

# Checks every frame if a player is trying to use hole
func _physics_process(_delta):
	if exit_point:
		if area.get_overlapping_bodies():
			for obj in area.get_overlapping_bodies():
				if obj.is_in_group("Player"):
					if !obj.rolling:
						if Input.is_action_just_pressed("%s_%s" % [obj.control_type, key]):
							exit_point.teleport(obj)
