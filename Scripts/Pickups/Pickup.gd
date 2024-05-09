extends RigidBody2D

@export var sprite : Sprite2D

# Shows all potential pickup types as a drop down
@export_enum (
	"Weapon", 
	"Item",
	) var type : String

@export var pickup_name: String


func _ready():
	sprite.texture = load("res://Sprites/Pickups/" + get_pickup_path() + ".png")

# Returns the name of this pickup
func get_pickup_path():
	return type + "s/" + pickup_name.to_lower()

# Runs any final cleanup code before destroying self
func destroy():
	queue_free()
