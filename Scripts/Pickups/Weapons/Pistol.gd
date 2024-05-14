extends Gun

# Called at start
func _ready():
	# Handles equivalent of "_ready()" in Gun parent class
	_on_ready()

# Handles attack when pickup is in hand
func attack():
	# Only allows shooting if ammo available and not reloading
	if ammo_count > 0 and reload_timer.is_stopped():
		shoot()
	
	# Automatically starts reload when out of bullets
	if ammo_count <= 0:
		ammo_count = max_ammo_count
		reload_timer.start()
