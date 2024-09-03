extends Control

# Called in player script; changes player's portrait depending on movement
signal alter_portrait(p_string : String, face_string : String)

# FOR DEBUG PURPOSES ONLY
func _physics_process(_delta):
	# Resets scene when "R" is pressed
	if (Input.is_action_just_pressed("keyboard_pause") or Input.is_action_just_pressed("controller_pause")):
		get_tree().reload_current_scene()
