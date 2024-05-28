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

enum state {LEFT, RIGHT, DOWN, UP}

func set_player(_player : CharacterBody2D):
	player = _player
	p_string = player.p_string

# 
func create_hole(hole_state) -> Node2D:
	var offset = Vector2(0, 0)
	var key
	if hole_state == state.DOWN:
		offset = Vector2(0, 55)
		key = "down"
	elif hole_state == state.LEFT:
		offset = Vector2(-55, 0)
		key = "left"
	elif hole_state == state.RIGHT:
		offset = Vector2(55, 0)
		key = "right"
		
	var hole = HOLE.instantiate()
	hole.global_position = player.global_position
	hole.sprite.global_position += offset
	
	hole.set_key(key)
	
	player.signal_handler.add_child(hole)
	return hole

#
func dig(hole_state) -> void:
	if !hole1:
		hole1 = create_hole(hole_state)
	elif !hole2:
		hole2 = create_hole(hole_state)
		
		hole1.set_exit(hole2)
		hole2.set_exit(hole1)
	else:
		hole1.queue_free()
		hole1 = hole2
		
		hole2 = create_hole(hole_state)
		
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
				dig(state.DOWN)
				double_tap_timer.stop()
		else:
			button_tapped = p_string + "down"
			double_tap_timer.start()
	
	if Input.is_action_just_pressed(p_string + "left"):
		if !double_tap_timer.is_stopped() and button_tapped == p_string + "left":
			if player.is_on_wall():
				dig(state.LEFT)
				double_tap_timer.stop()
		else:
			button_tapped = p_string + "left"
			double_tap_timer.start()
			
	if Input.is_action_just_pressed(p_string + "right"):
		if !double_tap_timer.is_stopped() and button_tapped == p_string + "right":
			if player.is_on_wall():
				dig(state.RIGHT)
				double_tap_timer.stop()
		else:
			button_tapped = p_string + "right"
			double_tap_timer.start()
