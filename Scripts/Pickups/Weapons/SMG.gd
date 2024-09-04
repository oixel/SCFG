extends Gun

# Handles gap between each bullet shot by SMG
@export var gap_time : float = 0.025
var gap_timer : Timer = Timer.new()

# Prevents auto shooting when pickup button is held after picking up
var just_picked_up : bool = true

# Stores player's control type for cleaner input checking
var control_type

# Called at start
func _ready():
	# Handles equivalent of "_ready()" in Gun parent class
	_on_ready()
	
	# Initializes timer for gaps between each bullet
	gap_timer.one_shot = true
	gap_timer.wait_time = gap_time
	add_child(gap_timer)
	
	# Sets control type from player's object
	control_type = player.control_type

# Summons bullet and subtracts from ammo count
# Handles actual attacking for SMG
func _physics_process(_delta):
	# Waits until grab button is released before allowing shooting
	if just_picked_up and Input.is_action_just_released("%s_attack" % control_type):
		just_picked_up = false
	
	# Combines boolean statements for cleaner code
	var loaded = ammo_count > 0 and reload_timer.is_stopped()
	
	# Only shoots gun when it has ammo and is not currently reloading
	if Input.is_action_pressed("%s_attack" % control_type) and loaded and !just_picked_up:
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
