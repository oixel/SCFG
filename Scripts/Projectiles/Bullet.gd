extends Area2D

# Different properties for bullet's behavior
@export var speed : int = 500
@export var damage : int = 4
@export var knockback : int = 1
var player

# Stores which direction the bullet should be moving
var direction = Vector2(1, 1)

# Setter for bullet's direction
func initialize(_direction, _player):
	direction = _direction
	player = _player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Moves bullet in proper direction each frame
	position += speed * direction * delta
	
	# If collision with something occurs
	if get_overlapping_bodies():
		for obj in get_overlapping_bodies():
			# Prevents you from shooting yourself
			if obj == player:
				continue
			# Damages player if hit
			if obj.is_in_group("Player"):
				# Try to damage player
				if obj.hit(damage, knockback, direction.x):
					# If hit is successful (player is not rolling), destroy bullet
					queue_free()
			# Ignores pickups on group and destroys self on collisions with map
			elif !obj.is_in_group("Pickup"):
				queue_free()
