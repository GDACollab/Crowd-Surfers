extends Camera3D

@export var ray_path: NodePath
@export var player_path: NodePath
@export var follow_speed: float = 0.5

@onready var player: CharacterBody3D = get_node(player_path)
@onready var ray: RayCast3D = get_node(ray_path)

@export var offset: Vector3 = Vector3(0, 10000, 10000)

@export_category("Building Occlusion")
## The distance in front of the player that the transparency window's center should be at
@export var transparency_window_lead_distance := Vector3(50.0, 0.0, 0.0)
## The (x, y) distances of either end of the transparency window from its center
@export var transparency_window_scale := Vector2(100.0, 25.0)
## The speed at which the transparency window travels towards its lead position
@export var transparency_window_speed : float = 15.0
## The amount of transparency buildings should provide, where 0.0 means full transparency and 1.0 means full opacity
@export_range(0.0, 1.0) var alpha_amount : float = 0.5

var lead_smoothed: Vector3 = Vector3.ZERO
var transparency_window_pos := Vector3.ZERO

func _ready() -> void:
	transparency_window_pos = player.global_position

func _process(delta: float) -> void:
	var v: Vector3 = player.velocity
	# Calculate the camera's lead
	var lead_target: Vector3 = v.normalized() * sqrt(v.length() + 1.0) * 3.0
	lead_smoothed = lead_smoothed.lerp(
		lead_target,
		1.0 - exp(-follow_speed * delta)
	)
	global_position = player.global_position + offset + lead_smoothed
	# Get the player's center
	var player_collision_height = player.get_node("CollisionShape3D").shape.height
	var player_center_pos := player.global_position + Vector3(0, player_collision_height / 2.0, 0)
	# Get the target position for the transparency window
	var transparency_window_target_pos : Vector3 = player_center_pos + \
		transparency_window_lead_distance * sign(player.velocity.x)
	# Move the transparency window towards its target
	transparency_window_pos = transparency_window_pos.lerp(
		transparency_window_target_pos,
		1.0 - exp(-transparency_window_speed * delta)
	)
	
	# Pass values to the shader
	RenderingServer.global_shader_parameter_set("transparency_window_pos", transparency_window_pos)
	RenderingServer.global_shader_parameter_set("transparency_window_scale", transparency_window_scale)
	RenderingServer.global_shader_parameter_set("player_pos", player.global_position)
	RenderingServer.global_shader_parameter_set("alpha_amount", alpha_amount)
	
	#
	#ray.force_raycast_update()
	#var collider = ray.get_collider()
	#if collider:
		#for child in collider.get_children():
			#if child is Sprite3D:
				#child.hide()
