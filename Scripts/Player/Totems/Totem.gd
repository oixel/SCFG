extends CharacterBody2D

@export var totem_point : Node

var fly_speed = 300
var velo = Vector2(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target_position = (totem_point.global_position - global_position).normalized()
	
	var distance = global_position.distance_to(totem_point.global_position)
	
	if distance > 3:
		velocity = target_position * fly_speed
		move_and_slide()
