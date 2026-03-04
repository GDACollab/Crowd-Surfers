extends CollisionShape3D

@export var sky_pitch_degrees: float = 15.0
@export var crosshatch_shader: Shader

var faded: Array[Sprite3D] = []
var original_materials: Dictionary = {}

func _process(_delta: float) -> void:
	for s: Sprite3D in faded:
		if is_instance_valid(s):
			s.material_override = original_materials.get(s, null)
	faded.clear()
	original_materials.clear()

	var capsule := shape as CapsuleShape3D
	if not capsule:
		return

	var camera: Camera3D = get_viewport().get_camera_3d()
	var player: Node3D = get_parent() as Node3D
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from: Vector3 = player.global_position + Vector3(0.0, (capsule.height + capsule.radius * 2.0), 0.0)

	var to_camera: Vector3 = camera.global_position - from
	var dist: float = to_camera.length()
	var dir: Vector3 = to_camera / dist

	var right_axis: Vector3 = camera.global_transform.basis.x.normalized()
	var pitched_dir: Vector3 = dir.rotated(right_axis, deg_to_rad(-sky_pitch_degrees)).normalized()

	var query := PhysicsRayQueryParameters3D.create(from, from + pitched_dir * dist)
	query.exclude = [player]

	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return

	var collider := hit["collider"] as Node
	var sprites := collider.find_children("*", "Sprite3D", true, false)
	if sprites.is_empty():
		return

	var sprite := sprites[0] as Sprite3D
	if not original_materials.has(sprite):
		original_materials[sprite] = sprite.material_override

	var mat := ShaderMaterial.new()
	mat.shader = crosshatch_shader
	mat.set_shader_parameter("albedo_texture", sprite.texture)
	sprite.material_override = mat
	faded.append(sprite)
