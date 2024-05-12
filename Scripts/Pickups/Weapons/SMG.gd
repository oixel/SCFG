extends Node2D

# Stores max amount of bullets able to be shot before having to reload
@export var max_ammo_count : int = 12
var ammo_count : int

# Stores time that it takes for gun to automatically reload
@export var reload_time : float = 1.5
var reload_timer : Timer = Timer.new()

# Stores player carrying gun to detect when attack is called
var player

# Preloads bullet scene for instantiating when shooting
const BULLET = preload("res://Scenes/Projectiles/bullet.tscn")

# Called at start
func _ready():
	# Handles reload time
	reload_timer.one_shot = true
	reload_timer.wait_time = reload_time
	add_child(reload_timer)
	
	# Sets current ammo count to the max for this gun
	ammo_count = max_ammo_count

# Sets player that holds this pickup
func set_player(_player):
	player = _player

# Handles actual attacking for SMG
func _physics_process(delta):
	if Input.is_action_pressed(player.p_string + "attack"):
		print("Running")

# Ensures attack fuction exists for call in player's script but does nothing
func attack():
	pass
