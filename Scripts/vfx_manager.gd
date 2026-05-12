extends Node3D

@export_category("Parameters")
@export var vfx_clear_time: float = 5.0

@export_category("VFX Scenes")
@export var scene_dictionary: Dictionary[String, PackedScene] = {}

@export_category("VFX Offsets")
@export var offset_dictionary: Dictionary[String, Vector2] = {}

func spawn_vfx(vfx_position: Vector3, player_velocity: Vector3, vfx_name: String):	
	var player_flat_velocity: Vector2 = Vector2(player_velocity.x, player_velocity.z)
	
	if (!scene_dictionary.has(vfx_name)):
		print("ERROR: VFX name not found!!")
		return
		
	var vfx: AnimatedSprite3D = scene_dictionary[vfx_name].instantiate()
	var offset: Vector2 = offset_dictionary[vfx_name]
	
	if (player_flat_velocity.x > 0):
		vfx.scale.x *= -1
		
	if (abs(player_flat_velocity.y) > abs(player_flat_velocity.x)):
		vfx.rotation.y = -90
	
	offset = offset.rotated(player_flat_velocity.angle())
	print(Vector3(offset.x, 0, offset.y))
	vfx.position = vfx_position + Vector3(offset.x, 0, offset.y);
	add_child(vfx)
	
	# Delete vfx after vfx_clear_time seconds
	await get_tree().create_timer(vfx_clear_time).timeout
	vfx.queue_free()
