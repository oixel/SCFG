extends Node

var player : CharacterBody2D
var normal_weight
var glide_weight = 0.05
var p_string : String

var hold_time = 0
var glide_time_min = 0.225

var max_jumps : int = 3
var jump_count : int = 0

func set_player(_player : CharacterBody2D):
	player = _player
	p_string = player.p_string
	normal_weight = player.weight

func _physics_process(delta):
	if (player.is_on_floor()):
		# Resets jump counter when landing on ground
		jump_count = 0
		
		# Resets glide variable when landing on ground
		hold_time = 0
		player.weight = normal_weight
	else:
		# Updates time for glide button being held
		if Input.is_action_pressed(p_string + "up"):
			hold_time += delta
		
		# Resets glide hold time if button is released
		if Input.is_action_just_released(p_string + "up"):
			hold_time = 0
		
		# Changes player weight depending if glide button is being held
		player.weight = glide_weight if hold_time >= glide_time_min else normal_weight
		
		# Allows for multiple jumps
		if (Input.is_action_just_pressed(p_string + "up")): 
			if (jump_count < max_jumps):
				player.jump()
				jump_count += 1
