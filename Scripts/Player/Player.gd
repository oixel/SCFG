extends CharacterBody2D

@export var player_number = 1
@onready var p_string = "P" + str(player_number) + "_"

@export var signal_handler : Node

@export var totem_point : Node


@onready var sprite = $PlayerSprite
@onready var sprite_start_scale = sprite.scale.y
@onready var collider = $Collider
@onready var collider_start_scale = collider.scale.y

const WEIGHT = 6
const WALK_SPEED = 500.0
const CROUCH_SPEED = 250.0
const JUMP_STRENGTH = 12

@onready var speed = WALK_SPEED

const CROUCH_TWEEN_SPEED = 0.025

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#
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
	
	# 
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

	# 
	signal_handler.emit_signal("alter_portrait", p_string, "idle")
	
	# Causes player to move at normal speed again
	speed = WALK_SPEED

# Kills player
func die():
	signal_handler.emit_signal("alter_portrait", p_string, "Dead")
	queue_free()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * WEIGHT * delta

	# Handle jump.
	if Input.is_action_just_pressed(p_string + "up") and is_on_floor():
		jump()
	
	# Handle crouching
	if Input.is_action_just_pressed(p_string + "down"):
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
