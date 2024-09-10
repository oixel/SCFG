extends Node2D

@export var damage : int = 10

var cooldown_timer : Timer = Timer.new()
var cooldown_time : float = 1

var player

# Sets player that holds this pickup
func set_player(_player):
	player = _player

# Called at start
func _ready():
	# Changes player's damage to do more
	player.melee_damage = damage
	
	# Sets up cooldown timer
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown_time
	add_child(cooldown_timer)

# Handles attack when pickup is in hand
func attack():
	if cooldown_timer.is_stopped():
		player.attack()
		cooldown_timer.start()
