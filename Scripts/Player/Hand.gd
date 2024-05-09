extends Node2D

var is_empty : bool = true
@export var sprite : Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func pickup(item_name):
	sprite.texture = load("res://Sprites/Pickups/" + item_name + ".png")
	is_empty = false
