extends CharacterBody2D

# Used in altering portrait's reaction
@export var signal_handler : Node

# Differentiates player controls depending on if 1 or 2
@export_range(1, 2) var player_number : int

@export_enum("keyboard", "controller") var control_type : String

# Used to check button presses for different players
@onready var p_string = "P" + str(player_number) + "_"

#
@export var animation_player : AnimationPlayer

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

var crouched = false
var rolling = false
var can_roll = true
var dodging = false
var can_stiff_dodge = true
var roll_ready = true  # Prevents spamming roll button
var air_dodge_ready = false  # Prevents infinite air dodging by only reseting when floor is touched

# Allows for coyote time when falling off ledge
var coyote_timer : Timer = Timer.new()
var coyote_time : float = 0.1

# Invulnerability is applied when player rolls or dodges in place
var roll_timer : Timer = Timer.new()
var roll_time : float = 0.4
var dodge_timer : Timer = Timer.new()
var dodge_time : float = 0.20

# The amount of time that roll / dodging takes before it can be used again
var roll_refresh_timer : Timer = Timer.new()
var roll_refresh_time : float = 0.5

# Handles melee cooldown
var melee_cooldown_timer : Timer = Timer.new()
var melee_cooldown_time : float = 0.3

# Refers to the speed boosts obtained when rolling
const ROLL_BOOST = 300
const AIR_ROLL_VERT_BOOST = -250

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

# Tracks what button would cut rolling boost short
var opposite = "left"

# Keeps track of what way the player should be facing
var look_direction = 1
@onready var aim_sprite = $AimManager/AimLineSprite

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

# Re-enables rolling and dodging (called on reload timer's timeout)
func _reset_roll():
	roll_ready = true
	
	# Changes visibility of dodge icon to indicate dodge availability
	signal_handler.emit_signal("change_dodge_icon", p_string, roll_ready)

# Called in roll and dodge functions to handle spam prevention
func start_roll_refresh():
	# Starts refresh time and sets state instantly
	roll_refresh_timer.start()
	roll_ready = false
	
	# Changes visibility of dodge icon to indicate dodge availability
	signal_handler.emit_signal("change_dodge_icon", p_string, roll_ready)

# Plays roll animation and grants temporary invulnerability
func roll():
	# Prevents any rolling if in the air and no air roll is available
	if !is_on_floor() and !air_dodge_ready:
		return
	
	# Plays basic rolling animation
	animation_player.play("roll")
	
	# Air rolls or regular rolls depdening on grounded status
	if !is_on_floor():
		# Applies both horizontal and vertical roll boosts when air rolling
		velocity.y = 0
		added_forces = Vector2(direction * ROLL_BOOST, AIR_ROLL_VERT_BOOST)
		
		air_dodge_ready = false
	else:
		# Applies only horizontal roll boost if rolling on ground
		added_forces = Vector2(direction * ROLL_BOOST, 0)
	
	# Starts timer that resets rolling state when it times out
	roll_timer.start()
	rolling = true
	
	# Prevents roll spam
	start_roll_refresh()

# Resets rolling state (called on rolling timer's timeout)
func _end_rolling():
	rolling = false

# Dodges in place
func dodge():
	# Plays dodging in place animation
	animation_player.play("dodge")
	
	# Starts timer that resets dodging state when it times out
	dodge_timer.start()
	dodging = true
	
	# Prevents infinite air dodging
	if !is_on_floor():
		air_dodge_ready = false
	
	# Prevents dodge spam
	start_roll_refresh()

# Resets dodging state (called on dodging timer's timeout)
func _end_dodging():
	dodging = false

# Makes player crouch down
func crouch():
	# Enable all crouched parts of player
	$Sprites/CrouchedSprite.show()
	$Sprites/CrouchedEyeSprite.show()
	$CrouchedCollider.disabled = false
	
	# Disable all standing parts of player
	$Sprites/PlayerSprite.hide()
	$Sprites/EyeSprite.hide()
	$Collider.disabled = true
	
	# Changes portrait's reaction to be crouching
	signal_handler.emit_signal("alter_portrait", p_string, "crouch")
	
	crouched = true

# Makes player stand up from crouch
func stand_up():
	# Enable all standing parts of player
	$Sprites/PlayerSprite.show()
	$Sprites/EyeSprite.show()
	$Collider.disabled = false
	
	# Disable all crouching parts of player
	$Sprites/CrouchedSprite.hide()
	$Sprites/CrouchedEyeSprite.hide()
	$CrouchedCollider.disabled = true
	
	# Changes portrait's reaction back to normal
	signal_handler.emit_signal("alter_portrait", p_string, "idle")
	
	crouched = false

# Handles attacking when empty handed
func attack():
	animation_player.play("attack")
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
	# Only allows damage when not in an invulnerable state
	if !rolling and !dodging:
		# Damages player and updates health text
		health -= damage
		health_text.text = "[center]" + str(health)
		
		# Applies knockback in direction of hit
		added_forces = Vector2((knockback - knockback_resistance) * 1000 * hit_direction, knockback * -300)
		
		# Kills player when health gets too low
		if health <= 0:
			die()
		
		# Returns true since damaging attempt succeeded
		return true
	
	# Returns fall if damaging attempt fails
	return false

# Kills player
func die():
	# Changes portrait to skull and deletes player object
	signal_handler.emit_signal("alter_portrait", p_string, "Dead")
	queue_free()

# Called at start
func _ready():
	# Handles coyote time when moving off ledges
	coyote_timer.one_shot = true
	coyote_timer.wait_time = coyote_time
	add_child(coyote_timer)
	
	# Handles invulnerability caused by roll time
	roll_timer.one_shot = true
	roll_timer.wait_time = roll_time
	roll_timer.timeout.connect(_end_rolling)
	add_child(roll_timer)
	
	dodge_timer.one_shot = true
	dodge_timer.wait_time = dodge_time
	dodge_timer.timeout.connect(_end_dodging)
	add_child(dodge_timer)
	
	# Handles the time that it takes before roll or dodge can be used again
	roll_refresh_timer.one_shot = true
	roll_refresh_timer.wait_time = roll_refresh_time
	roll_refresh_timer.timeout.connect(_reset_roll)
	add_child(roll_refresh_timer)
	
	# Sets up melee cooldown timer
	melee_cooldown_timer.one_shot = true
	melee_cooldown_timer.wait_time = melee_cooldown_time
	add_child(melee_cooldown_timer)
	
	# Sets p_string in aim manager
	aim_manager.set_control_type(control_type)
	
	# Updates transform of aim manager
	aim_manager.transform.x.x = sign(1)

func _physics_process(delta):		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * weight * delta
		
	if is_on_floor():
		coyote_timer.start()
	
	# Resets air dodge
	if !air_dodge_ready:
		if is_on_floor():
			air_dodge_ready = true
	
	# Pauses gravity when dodging unless using a totem like bird (to prevent abuse)
	if dodging:
		velocity.y = 0
	
	# Stops rolling if the opposite button is pressed
	if rolling and is_on_floor():
		if Input.is_action_just_pressed("%s_%s" % [control_type, opposite]):
			velocity.x = 0
			rolling = false
			roll_timer.stop()
			animation_player.stop()
			animation_player.play("halt")
	
	# Handle jump if in a state where jumping is allowed
	if Input.is_action_just_pressed("%s_up" % control_type) and !coyote_timer.is_stopped() and !rolling and !dodging and !crouched:
		jump()
		coyote_timer.stop()  # If jump occurs, instantly end coyote time to prevent spam jumping
	
	# Creates arch for better control while jumping
	if Input.is_action_just_released("%s_up" % control_type) and velocity.y < -500:
		velocity.y = -500
	
	# Handle crouching
	if Input.is_action_pressed("%s_down" % control_type) and is_on_floor() and !crouched and !rolling:
		crouch()
	elif !Input.is_action_pressed("%s_down" % control_type) and crouched:
		stand_up()
	
	# Handles rolling / dodging if not already in the process of either and if not in refresh period
	if Input.is_action_just_pressed("%s_roll" % control_type) and !rolling and !dodging and roll_ready:
		if direction and !crouched and can_roll:
			roll_direction = direction
			opposite = "left" if direction > 0 else "right"
			roll()
		elif can_stiff_dodge and air_dodge_ready:
			dodge()
	
	# Plays animation and attempts to attack in front of player
	if Input.is_action_just_pressed("%s_attack" % control_type) and !rolling and !dodging:
		if hand.is_empty:
			if melee_cooldown_timer.is_stopped():
				attack()
				melee_cooldown_timer.start()
		else:
			hand.attack()
	
	# Causes player to move at normal speed again
	speed = crouch_speed if crouched else walk_speed
	
	# Prevents chage of direction while rolling
	if !rolling and !dodging:
		# Get the input direction and handle the movement/deceleration.
		direction = Input.get_axis("%s_left" % control_type, "%s_right" % control_type)
	elif rolling:
		direction = roll_direction
	else:
		direction = 0
	
	# Ends walking animation when no longer walking 
	if direction == 0 and animation_player.current_animation == "walk":
		animation_player.stop()
	
	if direction and !rolling:
		if !animation_player.is_playing() and is_on_floor():
			animation_player.play("walk")
		velocity.x = direction * speed
	elif !rolling:
		if !direction and !animation_player.is_playing():
			animation_player.play("RESET")
		velocity.x = move_toward(velocity.x, 0, speed)
	
	# Flips transform of player depending on whether aiming is required
	if !need_aiming and direction != 0: 
		look_direction = sign(direction)
	elif need_aiming:
		# Uses the rotation of the aim sprite to make player face the direction they're aiming
		var rot = aim_sprite.rotation_degrees
		var looking_left = (-270 < rot and rot < -90) or (90 < rot and rot < 270)
		look_direction = -1 if looking_left else 1
	
	# Alters the player to face the proper direction (either of movement or aim depending on state)
	transform.x.x = look_direction
	health_text.get_parent().transform.x.x = look_direction
	aim_manager.transform.x.x = look_direction
	
	# Applies knockback to player
	velocity += added_forces
	
	move_and_slide()
	
	# Slowly resets forces back to zero to avoid infinite knockback
	if added_forces != Vector2(0, 0):
		var tween = create_tween()
		tween.tween_property(self, "added_forces", Vector2(0, 0), APPLIED_FORCE_TWEEN_SPEED)
