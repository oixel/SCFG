extends Node2D

# Stores max amount of bullets able to be shot before having to reload
@export var max_ammo_count : int = 12
var ammo_count : int

# Handles how much damage each bullet does
@export var bullet_damage : int = 2

# Handles gap between each bullet shot by SMG
@export var gap_time : float = 0.025
var gap_timer : Timer = Timer.new()

# Stores time that it takes for gun to automatically reload
@export var reload_time : float = 2
var reload_timer : Timer = Timer.new()

# Stores player carrying gun to detect when attack is called
var player

# Preloads bullet scene for instantiating when shooting
const BULLET = preload("res://Scenes/Projectiles/bullet.tscn")

# Called at start
func _ready():
	# Initializes timer for gaps between each bullet
	gap_timer.one_shot = true
	gap_timer.wait_time = gap_time
	add_child(gap_timer)
	
	# Initializes timer for reloading gun
	reload_timer.one_shot = true
	reload_timer.wait_time = reload_time
	add_child(reload_timer)
	
	# Sets current ammo count to zero to prevent shooting on pickup
	ammo_count = 0

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

# Handles actual attacking for SMG
func _physics_process(_delta):
	# Only shoots gun when it has ammo and is not currently reloading
	if Input.is_action_pressed(player.p_string + "attack") and ammo_count > 0 and reload_timer.is_stopped():
		# Waits a short time before firing each bullet to prevent clumping
		if gap_timer.is_stopped():
			shoot()
			gap_timer.start()
	# Reloads gun when out of ammo
	elif ammo_count <= 0:
		ammo_count = max_ammo_count
		reload_timer.start()

# Ensures attack fuction exists for call in player's script but does nothing
func attack():
	pass
