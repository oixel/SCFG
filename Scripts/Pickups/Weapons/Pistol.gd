extends Node2D

# Stores max amount of bullets able to be shot before having to reload
@export var max_ammo_count : int = 6
var ammo_count : int

# Handles how much damage each bullet does
@export var bullet_damage : int = 4

# Stores time that it takes for gun to automatically reload
@export var reload_time : float = 1.5
var reload_timer : Timer = Timer.new()

# Stores player carrying gun to detect when attack is called
var player

# Preloads bullet scene for instantiating when shooting
const BULLET = preload("res://Scenes/Projectiles/bullet.tscn")

# Called at start
func _ready():
	# Initializes timer for reloading gun
	reload_timer.one_shot = true
	reload_timer.wait_time = reload_time
	add_child(reload_timer)
	
	# Sets current ammo count to the max for this gun
	ammo_count = max_ammo_count

# Sets player that holds this pickup
func set_player(_player):
	player = _player

# Summons bullet and subtracts from ammo count
func shoot():
	# Subtracts one bullet from current count
	ammo_count -= 1
	
	# Instantiates bullet at player's projectile point
	var bullet = BULLET.instantiate()
	player.signal_handler.add_child(bullet)
	bullet.global_position = player.projectile_point.global_position
	
	# Changes bullet damage depending on exported variable
	bullet.damage = bullet_damage
	
	# Sets movement direction of bullet depending on which way the player is facing
	bullet.set_direction(sign(player.transform.x.x))

# Handles attack when pickup is in hand
func attack():
	# Only allows shooting if ammo available and not reloading
	if ammo_count > 0 and reload_timer.is_stopped():
		shoot()
	
	# Automatically starts reload when out of bullets
	if ammo_count <= 0:
		ammo_count = max_ammo_count
		reload_timer.start()
