extends Node3D

@export_category("Parameters")
@export var vfx_clear_time: float = 5.0

@export_category("VFX Scenes")
@export var scene_dictionary: Dictionary[String, PackedScene] = {}

@export_category("VFX Offsets")
@export var offset_dictionary: Dictionary[String, Vector3] = {}

@export_category("VFX Settings")
enum RotationSetting {NONE, FLIP, ROTATE}
@export var rotate_dictionary: Dictionary[String, RotationSetting] = {}

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
	
	if (rotate_dictionary[vfx_name] == RotationSetting.FLIP):
		if (player_flat_velocity.x > 0):
			vfx.flip_h = true
			
		if (abs(player_flat_velocity.y) > abs(player_flat_velocity.x)):
			vfx.rotation.y = -90
		
	elif (rotate_dictionary[vfx_name] == RotationSetting.ROTATE):
		# weird ahh code. turns velocity into an angle rounded to the nearest 45 degrees. each 45 degree angle goes from from 0 to 7
		var angle: float = round(4 * player_flat_velocity.angle() / PI)
		if (angle > 0):
			angle = 8 - angle
		angle = abs(angle)
		print((angle * PI / 4) + PI)
		
		vfx.rotation.y = (angle * PI / 4) + PI
	
	#cant be asked to make a whole dict for this
	if (vfx_name == "dash_side"): 
		offset += Vector3(0, 0, -3)
	vfx.position = vfx_position + offset
	
	if (parent_node == null):
		add_child(vfx)
	else:
		vfx.position -= parent_node.position
		parent_node.add_child(vfx)
	
	# Delete vfx after vfx_clear_time seconds
	await get_tree().create_timer(vfx_clear_time).timeout
	vfx.queue_free()
