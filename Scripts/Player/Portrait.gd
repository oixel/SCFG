extends Control

@export var face_texture : TextureRect

# 
func alter(texture : Texture):
	face_texture.texture = texture
