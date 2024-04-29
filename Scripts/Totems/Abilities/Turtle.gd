extends Node

var player : CharacterBody2D
var p_string : String

func set_player(_player : CharacterBody2D):
	player = _player
	p_string = player.p_string
