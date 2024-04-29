extends CharacterBody2D

@export var player : Node

@export_enum (
	"Bird", 
	"Frog", 
	"Octopus", 
	"Turtle"
	) var totem_name : String

var totem_point : Node
var ability_handler

var fly_speed = 300
var velo = Vector2(0, 0)

# Creates ability handler for totem's custom ability
func set_ability():
	$TotemSprite.texture = load("res://Sprites/Totems/" + totem_name + ".png")
	ability_handler = Node2D.new()
	ability_handler.name = "AbilityHandler"
	ability_handler.set_script(load("res://Scripts/Totems/Abilities/" + totem_name + ".gd"))
	ability_handler.set_player(player)
	ability_handler.set_process(true)
	ability_handler.set_physics_process(true)
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
		
		var gap = global_position.distance_to(totem_point.global_position)
		
		# Only move if there is a significant gap between totem and point
		if gap > 3:
			velocity = target_position * fly_speed
			move_and_slide()
	else:  # Deletes totem when player is destroyed
		ability_handler.queue_free()
		queue_free()
