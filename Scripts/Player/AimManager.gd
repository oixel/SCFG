extends Node2D

var p_string

@export var sprite : Sprite2D
var aim_rotation

# Timer that hides the aim line after a certain amount of time passes after aiming
@export var time_before_hide : float = 3
@onready var hide_timer  = Timer.new()

# Called on ready in player; sets p_string for this aim manager
func set_p_string(_p_string):
	p_string = _p_string

# Called at start
func _ready():
	# Initializes timer for hiding the aim line after aiming
	hide_timer.one_shot = true
	hide_timer.wait_time = time_before_hide
	add_child(hide_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#
	# VERY ROUGH TEST FOR AIMING
	#
	if Input.is_action_pressed(p_string + "aim_right"):
		sprite.rotation += 0.05
		if sprite.rotation > 360:
			sprite.rotation = 0
		
		# Ensures that aim line is visible when aiming
		if !sprite.visible:
			sprite.show()
			hide_timer.start()
	
	if Input.is_action_pressed(p_string + "aim_left"):
		sprite.rotation -= 0.05
		if sprite.rotation < -360:
			sprite.rotation = 0
		
		# Ensures that aim line is visible when aiming
		if !sprite.visible:
			sprite.show()
			hide_timer.start()
	
	aim_rotation = sprite.rotation
	
	#
	#
	#
	
	# Hides aim line if time has passed
	if hide_timer.is_stopped() and sprite.visible:
		sprite.hide()
