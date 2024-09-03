extends Node2D

# Sets name for this class to be Gun
class_name Gun

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

# Called at start from child class
func _on_ready():
	# Initializes timer for reloading gun
	reload_timer.one_shot = true
	reload_timer.wait_time = reload_time
	add_child(reload_timer)
	
	# Sets current ammo count to the max for this gun
	ammo_count = max_ammo_count

# Sets player that holds this pickup
func set_player(_player):
	player = _player
	
	# Ensures that player begins facing direction of aim and that aim sprite is visible
	player.need_aiming = true
	player.aim_sprite.show()

# Summons bullet and subtracts from ammo count
func shoot():
	# Subtracts one bullet from current count
	ammo_count -= 1
	
	# Instantiates bullet at player's projectile point
	var bullet = BULLET.instantiate()
	player.signal_handler.add_child(bullet)
	bullet.global_position = player.projectile_point.global_position
	bullet.rotation = player.aim_manager.aim_rotation
	
	# Changes bullet damage depending on exported variable
	bullet.damage = bullet_damage
	
	# Sets movement direction of bullet depending on which way the player is aiming
	var direction = Vector2(1, 0).rotated(player.aim_manager.aim_rotation)
	bullet.initialize(direction, player)
