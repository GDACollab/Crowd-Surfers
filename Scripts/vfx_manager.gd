extends Node3D

@export_category("Parameters")
@export var vfx_clear_time: float = 5.0

@export_category("VFX Scenes")
@export var scene_dictionary: Dictionary[String, PackedScene] = {}

@export_category("VFX Offsets")
@export var offset_dictionary: Dictionary[String, Vector3] = {}

@export_category("VFX Settings")
@export var rotate_dictionary: Dictionary[String, bool] = {}

func spawn_vfx(vfx_position: Vector3, player_velocity: Vector3, vfx_name: String, parent_node: Node = null):	
	var player_flat_velocity: Vector2 = Vector2(player_velocity.x, player_velocity.z)
	# Pretend we are facing forwards
	if (player_flat_velocity.length() == 0):
		player_flat_velocity = Vector2(0, 100)
		vfx_position.z-= 10

	if (!scene_dictionary.has(vfx_name)):
		print("ERROR: VFX name not found!!")
		return
		
	var vfx: AnimatedSprite3D = scene_dictionary[vfx_name].instantiate()
	
	var offset: Vector3 = offset_dictionary[vfx_name]
	var flat_offset: Vector2 = Vector2(offset.x, offset.z)
	flat_offset = flat_offset.rotated(player_flat_velocity.angle())
	offset = Vector3(flat_offset.x, offset.y, flat_offset.y)

	if (rotate_dictionary[vfx_name] == true):
		if (player_flat_velocity.x > 0):
			vfx.flip_h = true
			
		if (abs(player_flat_velocity.y) > abs(player_flat_velocity.x)):
			vfx.rotation.y = -90
	
	vfx.position = vfx_position + offset
	if (parent_node == null):
		add_child(vfx)
	else:
		vfx.position -= parent_node.position
		parent_node.add_child(vfx)
	
	# Delete vfx after vfx_clear_time seconds
	await get_tree().create_timer(vfx_clear_time).timeout
	vfx.queue_free()
