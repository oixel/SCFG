extends Node

var player : CharacterBody2D
var p_string : String

func set_player(_player : CharacterBody2D):
	player = _player
	p_string = player.p_string

func _physics_process(_delta):
	# Prevents code from running if player just died
	if player.health <= 0:
		return
