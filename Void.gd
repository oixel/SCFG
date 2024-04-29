extends Area2D

# Kills player and destroys objects that go too far down
func _on_body_entered(other):
	if (other.is_in_group("Player")):
		other.die()
