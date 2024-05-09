extends RigidBody2D

@export var pickup_name: String

# Returns the name of this pickup
func get_pickup_name():
	return pickup_name.to_lower()

# Runs any final cleanup code before destroying self
func destroy():
	queue_free()
