extends Node2D

var player

const BULLET = preload("res://Scenes/Projectiles/bullet.tscn")

# Sets player that holds this pickup
func set_player(_player):
	player = _player

# Handles attack when pickup is in hand
func attack():
	# Instantiates bullet at player's projectile point
	var bullet = BULLET.instantiate()
	player.signal_handler.add_child(bullet)
	bullet.global_position = player.projectile_point.global_position
	
	# Sets movement direction of bullet depending on which way the player is facing
	bullet.set_direction(sign(player.transform.x.x))
