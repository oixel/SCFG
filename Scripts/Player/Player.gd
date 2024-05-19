extends CharacterBody2D

# Used in altering portrait's reaction
@export var signal_handler : Node

# Differentiates player controls depending on if 1 or 2
@export_range(1, 2) var player_number : int

# Used to check button presses for different players
@onready var p_string = "P" + str(player_number) + "_"

# Stores player's hand node
@export var hand : Node

# Stores point where totem should go to
@export var totem_point : Node

# Stores the point where projectiles should be spawned
@export var projectile_point : Node

# Trigger area for melee damage and grab
@export var hit_area : Area2D

# Manager for all aspects of aiming weapons that need to be aimed
@export var aim_manager : Node2D

# Starting health
@export var health : int = 20
@export var health_text : RichTextLabel

# Damage that basic empty-handed melee attack does
@export var melee_damage : int = 5

# Invulnerability is applied when player rolls
var roll_timer : Timer = Timer.new()
var roll_time : float = 0.35

# Can be altered by totems to make player take less knockback
var knockback_resistance : float = 0

# Objects that get changed during crouch
@onready var sprite = $Sprites/PlayerSprite
@onready var sprite_start_scale = sprite.scale.y
@onready var collider = $Collider
@onready var collider_start_scale = collider.scale.y

# Different movement variables
var walk_speed = 500.0
var crouch_speed = 250.0
var jump_strength = 12
@onready var speed = walk_speed

var crouched = false
var rolling = false

# Changes how player's direction is handled depending if a pickup requires aiming
var need_aiming : bool = false

# Changes how fast player falls while in air
var weight = 6

# Changes how fast crouch animation occurs
const CROUCH_TWEEN_SPEED = 0.025

# Changes how fast applied forces should reset back to zero
const APPLIED_FORCE_TWEEN_SPEED = 0.03

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Keeps track of what direction player is moving
var direction

# Stores direction that player is moving when roll started
var roll_direction

# Added to velocity to replicate knockback
var added_forces : Vector2

# Returns totem point node for totem movement
func get_totem_point():
	return totem_point

# Makes player jump
func jump():
	velocity.y = jump_strength * -100

# Plays roll animation and grants temporary invulnerability
func roll():
	$AnimationPlayer.play("roll")
	roll_timer.start()

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
	
	crouched = true

# Makes player stand up from crouch
func stand_up():
	# Animates player to stand up
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(sprite, "global_scale:y", sprite_start_scale, CROUCH_TWEEN_SPEED)
	tween.tween_property(collider, "global_scale:y", collider_start_scale, CROUCH_TWEEN_SPEED)

	# Changes portrait's reaction back to normal
	signal_handler.emit_signal("alter_portrait", p_string, "idle")
	
	crouched = false

# Handles attacking when empty handed
func attack():
	$AnimationPlayer.play("attack")
	if hit_area.get_overlapping_bodies():
		for obj in hit_area.get_overlapping_bodies():
			# Damages player if in range
			if obj.is_in_group("Player"):
				obj.hit(melee_damage, 1, sign(transform.x.x))
			# Picks up any items if hand is currently empty
			elif obj.is_in_group("Pickup"):
				if hand.is_empty:
					hand.pickup(self, obj.get_pickup_path())
					obj.destroy()
					
					# Prevents application of weapon's damage if enemy in path of pickups
					break

# Takes damage and applies knockback when player is hit
func hit(damage, knockback, hit_direction):
	if !rolling:
		# Damages player and updates health text
		health -= damage
		health_text.text = "[center]" + str(health)
		
		# Applies knockback in direction of hit
		added_forces = Vector2((knockback - knockback_resistance) * 1000 * hit_direction, knockback * -300)
		
		# Kills player when health gets too low
		if health <= 0:
			die()
		
		return true
	return false

# Kills player
func die():
	# Changes portrait to skull and deletes player object
	signal_handler.emit_signal("alter_portrait", p_string, "Dead")
	queue_free()

# Called at start
func _ready():
	# Handles invulnerability caused by roll time
	roll_timer.one_shot = true
	roll_timer.wait_time = roll_time
	add_child(roll_timer)
	
	# Sets p_string in aim manager
	aim_manager.set_p_string(p_string)
	
	transform.x.x = sign(1)
	health_text.get_parent().transform.x.x = sign(1)
	aim_manager.transform.x.x = sign(1)

func _physics_process(delta):
	# Changes rolling state depending if the invulnerability timer is running
	rolling = false if roll_timer.is_stopped() else true
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * weight * delta
	
	# Handle jump.
	if Input.is_action_just_pressed(p_string + "up") and is_on_floor():
		jump()
	
	# Creates arch for better control while jumping
	if Input.is_action_just_released(p_string + "up") and velocity.y < -500:
		velocity.y = -500
	
	# Handle crouching
	if Input.is_action_just_pressed(p_string + "down") and is_on_floor():
		# Makes player roll if crouch is pressed while moving in a direction
		if direction:
			roll_direction = direction
			roll()
		else:
			crouch()
	elif Input.is_action_just_released(p_string + "down"):
		stand_up()
	
	# Plays animation and attempts to attack in front of player
	if Input.is_action_just_pressed(p_string + "attack") and !rolling:
		if hand.is_empty:
			attack()
		else:
			hand.attack()
	
	# Causes player to move at normal speed again
	speed = crouch_speed if crouched else walk_speed
	
	# Prevents chage of direction while rolling
	if !rolling:
		# Get the input direction and handle the movement/deceleration.
		direction = Input.get_axis(p_string + "left", p_string + "right")
	else:
		direction = roll_direction
	
	if direction:
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("walk")
		velocity.x = direction * speed
	else:
		if !direction and !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("RESET")
		velocity.x = move_toward(velocity.x, 0, speed)
	
	# Flips transform of player
	if !need_aiming and direction != 0: 
		transform.x.x = sign(direction)
		health_text.get_parent().transform.x.x = sign(direction)
		aim_manager.transform.x.x = sign(direction)
	# Else if need_aiming and get input on aiming buttons
	
	# Applies knockback to player
	velocity += added_forces
	
	move_and_slide()
	
	# Slowly resets forces back to zero to avoid infinite knockback
	if added_forces != Vector2(0, 0):
		var tween = create_tween()
		tween.tween_property(self, "added_forces", Vector2(0, 0), APPLIED_FORCE_TWEEN_SPEED)
