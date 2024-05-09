extends Node2D

@export var damage : int = 10

var player

# Sets player that holds this pickup
func set_player(_player):
	player = _player

# Called at start
func _ready():
	# Changes player's damage to do more
	player.melee_damage = damage

# Handles attack when pickup is in hand
func attack():
	player.attack()
