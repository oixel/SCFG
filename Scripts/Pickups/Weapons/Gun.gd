extends Node2D

var player

# Sets player that holds this pickup
func set_player(_player):
	player = _player

# Handles attack when pickup is in hand
func attack():
	print("Pew pew!")
