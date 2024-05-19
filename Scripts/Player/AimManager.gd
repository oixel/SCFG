extends Node2D

var p_string

@export var sprite : Sprite2D
var aim_rotation

# Called on ready in player; sets p_string for this aim manager
func set_p_string(_p_string):
	p_string = _p_string

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#
	# VERY ROUGH TEST FOR AIMING
	#
	if Input.is_action_pressed(p_string + "aim_right"):
		sprite.rotation += 0.05
		if sprite.rotation > 360:
			sprite.rotation = 0
	
	if Input.is_action_pressed(p_string + "aim_left"):
		sprite.rotation -= 0.05
		if sprite.rotation < -360:
			sprite.rotation = 0
	
	aim_rotation = sprite.rotation
	#
	#
	#
