extends Camera3D

@export var ray_path: NodePath
@export var player_path: NodePath
@export var follow_speed: float = 0.5

@onready var player: CharacterBody3D = get_node(player_path)
@onready var ray: RayCast3D = get_node(ray_path)

@export var offset: Vector3 = Vector3(0, 10000, 10000)

@export var occlusionShader: ShaderMaterial

var lead_smoothed: Vector3 = Vector3.ZERO


func _process(delta: float) -> void:
	var v: Vector3 = player.velocity
	var lead_target: Vector3 = v.normalized() * sqrt(v.length() + 1.0) * 3.0
	lead_smoothed = lead_smoothed.lerp(
		lead_target,
		1.0 - exp(-follow_speed * delta)
	)
	global_position = player.global_position + offset + lead_smoothed
	
	var player_view_pos = self.global_transform.affine_inverse() * player.global_position
	occlusionShader.set_shader_parameter("player_view_pos", player_view_pos)
	
	
	#
	#ray.force_raycast_update()
	#var collider = ray.get_collider()
	#if collider:
		#for child in collider.get_children():
			#if child is Sprite3D:
				#child.hide()
