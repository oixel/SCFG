extends Node2D

var p_string

# Stores aim line sprite
@export var sprite : Sprite2D

# Used by weapons that need aiming to shoot projectiles in correct direction
var aim_rotation

# Value by which the aim line is rotated every frame of input
@export var rotation_speed : float = 0.1

# Timer that hides the aim line after a certain amount of time passes after aiming
@export var time_before_hide : float = 3
@onready var hide_timer  = Timer.new()

# Called on ready in player; sets p_string for this aim manager
func set_p_string(_p_string):
	p_string = _p_string

# Called at start
func _ready():
	# Ensures that aim line is not visible at start
	sprite.hide()
	
	# Initializes timer for hiding the aim line after aiming
	hide_timer.one_shot = true
	hide_timer.wait_time = time_before_hide
	add_child(hide_timer)

# Rotates aim line depending on multiplier (-1 or 1)
func rotate_aim(multiplier, out_of_range) -> void:
	sprite.rotation += rotation_speed * multiplier
	
	# Ensures rotation doesn't go out of range of -360 < x < 360
	if out_of_range:
		sprite.rotation = 0
	
	# Ensures that aim line is visible when aiming
	if !sprite.visible:
		sprite.show()
		hide_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Rotates the aim line clockwise
	if Input.is_action_pressed(p_string + "aim_right"):
		rotate_aim(1, sprite.rotation > 360)
	
	# Rotates the aim line counter-clockwise
	if Input.is_action_pressed(p_string + "aim_left"):
		rotate_aim(-1, sprite.rotation < -360)
	
	# Temporary implementation of aiming with mouse
	if p_string == "P1_":
		sprite.look_at(get_global_mouse_position())
		if !sprite.visible:
			sprite.show()
			hide_timer.start()
	
	# Updates the aim_rotation variable to match the aim line
	aim_rotation = sprite.rotation
	
	# Hides aim line if time has passed
	if hide_timer.is_stopped() and sprite.visible:
		sprite.hide()
