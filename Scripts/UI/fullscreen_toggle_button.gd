extends "res://Scripts/UI/button_highlight.gd"

@export var to_windowed_texture : CompressedTexture2D
@export var to_fullscreen_texture : CompressedTexture2D

func _ready() -> void:
	var mode := DisplayServer.window_get_mode()
	print(mode)
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		texture_normal = to_windowed_texture
	else:
		texture_normal = to_fullscreen_texture


func _on_pressed() -> void:
	var mode := DisplayServer.window_get_mode()
	print(mode)
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		texture_normal = to_windowed_texture
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		texture_normal = to_fullscreen_texture
