extends Node

var player : CharacterBody2D
var p_string : String

# Used to check double tapping of movement direction
@onready var double_tap_timer = Timer.new()
const WAIT_TIME : float = 0.3
var button_tapped : String

@onready var HOLE = preload("res://Scenes/Misc/hole.tscn")
var hole1 = null
var hole2 = null

func set_player(_player : CharacterBody2D):
	player = _player
	p_string = player.p_string

#
func dig() -> void:
	if !hole1:
		hole1 = HOLE.instantiate()
		hole1.global_position = player.global_position
		player.signal_handler.add_child(hole1)
	elif !hole2:
		hole2 = HOLE.instantiate()
		hole2.global_position = player.global_position
		player.signal_handler.add_child(hole2)
		hole1.set_exit(hole2)
		hole2.set_exit(hole1)
	else:
		hole1.queue_free()
		hole1 = hole2
		
		hole2 = HOLE.instantiate()
		hole2.global_position = player.global_position
		player.signal_handler.add_child(hole2)
		
		hole1.set_exit(hole2)
		hole2.set_exit(hole1)

# Called at start
func _ready():
	# Initializes basic timer
	double_tap_timer.one_shot = true
	double_tap_timer.wait_time = WAIT_TIME
	add_child(double_tap_timer)

func _physics_process(_delta):
	# Prevents code from running if player just died
	if !player:
		return
	
	# Handles running to the right
	if Input.is_action_just_pressed(p_string + "down"):
		if !double_tap_timer.is_stopped() and button_tapped == p_string + "down":
			if player.is_on_floor() and !player.rolling:
				dig()
				double_tap_timer.stop()
		else:
			button_tapped = p_string + "down"
			double_tap_timer.start()
