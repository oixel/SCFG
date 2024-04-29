extends CharacterBody2D

@export var player : Node
var totem_point : Node
@export var texture : Texture

var fly_speed = 300
var velo = Vector2(0, 0)

# Intializes totem point and totem's sprite
func _ready():
	$TotemSprite.texture = texture
	totem_point = player.get_totem_point()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If player hasn't died, move to its totem point
	if is_instance_valid(totem_point):
		var target_position = (totem_point.global_position - global_position).normalized()
		
		var gap = global_position.distance_to(totem_point.global_position)
		
		# Only move if there is a significant gap between totem and point
		if gap > 3:
			velocity = target_position * fly_speed
			move_and_slide()
	else:  # Deletes totem when player is destroyed
		queue_free()
