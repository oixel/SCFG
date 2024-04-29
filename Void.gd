extends Area2D

func _on_body_entered(other):
	if (other.is_in_group("Player")):
		other.die()
