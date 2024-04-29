extends Control

@export var face_texture : TextureRect

# Changes face to whatever texture the portrait controller received
func alter(texture : Texture):
	face_texture.texture = texture
