extends Node2D

var is_empty : bool = true
@export var sprite : Sprite2D
var item : Node

# Handles picking up new item
func pickup(player, item_path):
	# Updates that hand is no longer empty
	is_empty = false
	
	# Sets item in hand's sprite and loads in item's scene
	sprite.texture = load("res://Sprites/Pickups/" + item_path + ".png")
	item = load("res://Scenes/Pickups/" + item_path + ".tscn").instantiate()
	
	# Sets player that grabbed pickup in item scene's script
	item.set_player(player)
	
	# Adds newly created pickup scene under hand node
	add_child(item)

# Calls item in hand's attack 
func attack():
	item.attack()
