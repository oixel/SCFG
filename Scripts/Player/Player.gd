extends CharacterBody2D

# Used in altering portrait's reaction
@export var signal_handler : Node

# Differentiates player controls depending on if 1 or 2
@export_range(1, 2) var player_number : int

# Used to check button presses for different players
@onready var p_string = "P" + str(player_number) + "_"

# Stores point where totem should go to
@export var totem_point : Node

# Objects that get changed during crouch
@onready var sprite = $PlayerSprite
@onready var sprite_start_scale = sprite.scale.y
@onready var collider = $Collider
@onready var collider_start_scale = collider.scale.y

# Different movement variables
const WALK_SPEED = 500.0
const CROUCH_SPEED = 250.0
const JUMP_STRENGTH = 12
@onready var speed = WALK_SPEED

# Changes how fast player falls while in air
var weight = 6

# Changes how fast crouch animation occurs
const CROUCH_TWEEN_SPEED = 0.025

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Returns totem point node for totem movement
func get_totem_point():
	return totem_point

# Makes player jump
func jump():
	velocity.y = JUMP_STRENGTH * -100

# Makes player crouch down
func crouch():
	# Animates player to crouch down
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(sprite, "global_scale:y", sprite_start_scale / 2, CROUCH_TWEEN_SPEED)
	tween.tween_property(collider, "global_scale:y", collider_start_scale / 2, CROUCH_TWEEN_SPEED)
	tween.tween_property(self, "position:y", position.y + 13, CROUCH_TWEEN_SPEED)
	
	# Changes portrait's reaction to be crouching
	signal_handler.emit_signal("alter_portrait", p_string, "crouch")
	
	# Causes player to move slower while crouching
	speed = CROUCH_SPEED

# Makes player stand up from crouch
func stand_up():
	# Animates player to stand up
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(sprite, "global_scale:y", sprite_start_scale, CROUCH_TWEEN_SPEED)
	tween.tween_property(collider, "global_scale:y", collider_start_scale, CROUCH_TWEEN_SPEED)

	# Changes portrait's reaction back to normal
	signal_handler.emit_signal("alter_portrait", p_string, "idle")
	
	# Causes player to move at normal speed again
	speed = WALK_SPEED

# Kills player
func die():
	# Changes portrait to skull and deletes player object
	signal_handler.emit_signal("alter_portrait", p_string, "Dead")
	queue_free()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * weight * delta

	# Handle jump.
	if Input.is_action_just_pressed(p_string + "up") and is_on_floor():
		jump()
	
	# Handle crouching
	if Input.is_action_just_pressed(p_string + "down") and is_on_floor():
		crouch()
	elif Input.is_action_just_released(p_string + "down"):
		stand_up()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis(p_string + "left", p_string + "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	# Flips transform of player
	if direction != 0: 
		transform.x.x = sign(direction)
	
	move_and_slide()
