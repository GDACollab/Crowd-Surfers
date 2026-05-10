extends Node3D

@export_category("Parameters")
@export var vfx_clear_time: float = 5.0

@export_category("VFX Scenes")
@export var scene_dictionary: Dictionary[String, PackedScene] = {}

@export_category("VFX Offsets")
@export var offset_dictionary: Dictionary[String, Vector3] = {}

func spawn_vfx(vfx_position: Vector3, player_flip: bool, vfx_name: String):	
	if (!scene_dictionary.has(vfx_name)):
		print("ERROR: VFX name not found!!")
		return
		
	var vfx: AnimatedSprite3D = scene_dictionary[vfx_name].instantiate()
	var offset: Vector3 = offset_dictionary[vfx_name]
	
	if (player_flip == false):
		vfx.scale.x *= -1
		offset *= -1
	
	vfx.position = vfx_position + offset
	add_child(vfx)
	
	# Delete vfx after vfx_clear_time seconds
	await get_tree().create_timer(vfx_clear_time).timeout
	vfx.queue_free()
