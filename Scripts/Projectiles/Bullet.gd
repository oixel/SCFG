extends Area2D

# Different properties for bullet's behavior
@export var speed : int = 500
@export var damage : int = 4
@export var knockback : int = 1

# Stores which direction the bullet should be moving
var direction = 1

# Setter for bullet's direction
func set_direction(dir):
	direction = dir

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Moves bullet in proper direction each frame
	position.x += speed * direction * delta
	
	# If collision with something occurs
	if get_overlapping_bodies():
		for obj in get_overlapping_bodies():
			# Damages player if hit
			if obj.is_in_group("Player"):
				# Try to damage player
				if obj.hit(damage, knockback, direction):
					# If hit is successful (player is not rolling), destroy bullet
					queue_free()
			# Ignores pickups on group and destroys self on collisions with map
			elif !obj.is_in_group("Pickup"):
				queue_free()
