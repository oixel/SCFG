extends Node2D

# Either mouse and keyboard or one of the controllers
var control_type

# Stores aim line sprite
@export var sprite : Sprite2D

# Used by weapons that need aiming to shoot projectiles in correct direction
var aim_rotation = 0

# Called on ready in player; sets control type for this aim manager
func set_control_type(_control_type):
	control_type = _control_type

# Handles aiming with the mouse when player is playing on keyboard
func mouse_aim():
	sprite.look_at(get_global_mouse_position())
	
	# Sets limit of aiming sprite's rotation to be between -360 and 360
	if sprite.rotation_degrees > 360 or sprite.rotation_degrees < -360:
		sprite.rotation = 0

	# Updates the aim_rotation variable to match the aim line
	aim_rotation = sprite.rotation

# Handles weird twitching created by very little stick drift
func handle_stick_drift(j_strength):
	if j_strength < 0 and j_strength > -0.1:
		j_strength = 0
	elif j_strength < 0.1 and j_strength > 0:
		j_strength = 0
	
	return j_strength

# Handles aiming with the right joystick when player is on controller
func controller_aim():
	var joystick_x = handle_stick_drift(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X))
	var joystick_y = handle_stick_drift(Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	
	# Grabs angle from joystick input strengths
	var angle = Vector2(joystick_x, joystick_y).angle()
	
	if angle != 0:
		sprite.rotation = angle
	
		# Sets limit of aiming sprite's rotation to be between -360 and 360
		if sprite.rotation_degrees > 360 or sprite.rotation_degrees < -360:
			sprite.rotation = 0

		# Updates the aim_rotation variable to match the aim line
		aim_rotation = sprite.rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Handles aimining depending on what control type is chosen
	if control_type == "keyboard":
		mouse_aim()
	elif control_type == "controller":
		controller_aim()
