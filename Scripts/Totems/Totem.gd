extends CharacterBody2D

# Gets player to follow
@export var player : Node

# Shows all potential totem options as a drop down
@export_enum (
	"Bird", 
	"Frog", 
	"Octopus", 
	"Turtle"
	) var totem_name : String

# Stores point where totem should fly to
var totem_point : Node

# Handles totem's special ability
var ability_handler

# Changes how fast totem moves to totem point
var fly_speed = 300

# Creates ability handler for totem's custom ability
func set_ability():
	# Changes totem's sprite to look like correct totem
	$TotemSprite.texture = load("res://Sprites/Totems/" + totem_name + ".png")
	
	# Creates a new node under totem and gives it the proper script
	ability_handler = Node2D.new()
	ability_handler.name = "AbilityHandler"
	ability_handler.set_script(load("res://Scripts/Totems/Abilities/" + totem_name + ".gd"))
	
	# Initializes which player to grant ability to
	ability_handler.set_player(player)
	
	# Allows ability handler to start running on every frame
	ability_handler.set_process(true)
	ability_handler.set_physics_process(true)
	
	# Appends ability handler to totem!
	add_child(ability_handler)

# Intializes totem point and totem's sprite
func _ready():
	totem_name = totem_name.capitalize()
	set_ability()
	totem_point = player.get_totem_point()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# If player hasn't died, move to its totem point
	if is_instance_valid(totem_point):
		var target_position = (totem_point.global_position - global_position).normalized()
		
		# Tracks how far totem is from totem point
		var gap = global_position.distance_to(totem_point.global_position)
		
		# Only move if there is a significant gap between totem and point
		if gap > 3:
			velocity = target_position * fly_speed
			move_and_slide()
	else:  # Deletes totem when player is destroyed
		ability_handler.queue_free()
		queue_free()
