class_name Transparency extends Resource

var top_sprite: Sprite3D
var front_sprite: Sprite3D

func _init(in_top_sprite: Sprite3D, in_front_sprite: Sprite3D):
	top_sprite = in_top_sprite
	front_sprite = in_front_sprite

func set_do_transparency(do_transparency: bool) -> void:
	if top_sprite:
		top_sprite.set_instance_shader_parameter("do_transparency", do_transparency)
	if front_sprite:
		front_sprite.set_instance_shader_parameter("do_transparency", do_transparency)
