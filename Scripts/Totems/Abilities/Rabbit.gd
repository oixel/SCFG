extends Node

var player : CharacterBody2D
var p_string : String

const JUMP_MULTIPLIER : float = 1.25
const RUN_MULTIPLIER : float = 1.3

# Tracks whether player is running
var running = false

# Stores all movement speeds for easier changing
var walk_speed
var crouch_speed
var run_speed
var crouch_run_speed

# Used to check double tapping of movement direction
var double_tap_timer : Timer
const WAIT_TIME : float = 0.3
var button_tapped : String

# Default set_player function for all totems
func set_player(_player : CharacterBody2D):
	player = _player
	p_string = player.p_string

func _ready():
	# Initializes basic timer
	double_tap_timer = Timer.new()
	double_tap_timer.one_shot = true
	double_tap_timer.wait_time = WAIT_TIME
	add_child(double_tap_timer)
	
	# Increases player's jump strength by multiplier
	player.jump_strength = player.jump_strength * JUMP_MULTIPLIER
	
	# Stores basic move speeds and run speeds in variables
	walk_speed = player.walk_speed
	crouch_speed = player.crouch_speed
	run_speed = walk_speed * RUN_MULTIPLIER
	crouch_run_speed = crouch_speed * RUN_MULTIPLIER

func _physics_process(_delta):
	# Prevents code from running if player just died
	if !player:
		return
	
	# Stops running when direction is let go
	if Input.is_action_just_released(p_string + "right") or Input.is_action_just_released(p_string + "left") and running:
		running = false
	
	# Handles running to the right
	if Input.is_action_just_pressed(p_string + "right"):
		if !double_tap_timer.is_stopped() and button_tapped == p_string + "right" and !running:
			running = true
			double_tap_timer.stop()
		else:
			button_tapped = p_string + "right"
			double_tap_timer.start()
	
	# Handles running to the left
	if Input.is_action_just_pressed(p_string + "left"):
		if !double_tap_timer.is_stopped() and button_tapped == p_string + "left" and !running:
			running = true
			double_tap_timer.stop()
		else:
			button_tapped = p_string + "left"
			double_tap_timer.start()
	
	# Changes player's movement speed if running
	if running:
		player.walk_speed = run_speed
		player.crouch_speed = crouch_run_speed
	else:
		player.walk_speed = walk_speed
		player.crouch_speed = crouch_speed
