extends Control

@export var face_texture : TextureRect
@export var dodge_icon : TextureRect

# Changes face to whatever texture the portrait controller received
func alter(texture : Texture):
	face_texture.texture = texture

# Toggles visibility of dodge icon to indiciate whether a dodge is available
func change_dodge_icon(state : bool):
	dodge_icon.visible = state
