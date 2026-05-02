extends Camera3D

@export var player_path: NodePath
@export var follow_speed: float = 0.5
@export var offset: Vector3 = Vector3(0, 100, 100)

@export_category("Sprite Occlusion")
@export var occlusion_material: ShaderMaterial
@export var occlusion_alpha: float = 0.35
@export var fade_duration: float = 0.2
@export var player_half_width: float = 0.5
@export var player_half_height: float = 7.5
@export var occlusion_push: float = 1.0

@onready var player: CharacterBody3D = get_node(player_path)

var lead_smoothed := Vector3.ZERO
var occluding := {}
var pyramid_shape := ConvexPolygonShape3D.new()
var query := PhysicsShapeQueryParameters3D.new()

func _ready() -> void:
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [player.get_rid()]

func _process(delta: float) -> void:
	var v := player.velocity
	lead_smoothed = lead_smoothed.lerp(v.normalized() * sqrt(v.length() + 1.0) * 3.0, 1.0 - exp(-follow_speed * delta))
	global_position = player.global_position + offset + lead_smoothed

	# build a pyramid from the camera down to the player to catch anything blocking the view
	var center := player.global_position + Vector3.UP * occlusion_push
	var r := global_transform.basis.x * player_half_width
	var h := Vector3.UP * player_half_height
	pyramid_shape.points = PackedVector3Array([
		global_position,
		center + r + h, center - r + h,
		center - r - h, center + r - h,
	])

	query.shape = pyramid_shape
	var results := get_world_3d().direct_space_state.intersect_shape(query, 32)

	var newly_occluding := {}
	for hit in results:
		var collider := hit["collider"] as Node
		if collider == null:
			continue
		for child in collider.get_children():
			if child is Sprite3D or child is AnimatedSprite3D:
				var sprite := child as GeometryInstance3D
				newly_occluding[sprite] = true
				if not occluding.has(sprite):
					apply_occlusion(sprite)

	# anything that was occluding last frame but isn't anymore gets faded back in
	for sprite in occluding.keys().duplicate():
		if not is_instance_valid(sprite):
			occluding.erase(sprite)
		elif not newly_occluding.has(sprite):
			remove_occlusion(sprite)

func get_sprite_texture(sprite: GeometryInstance3D) -> Texture2D:
	if sprite is Sprite3D:
		return (sprite as Sprite3D).texture
	if sprite is AnimatedSprite3D:
		var a := sprite as AnimatedSprite3D
		if a.sprite_frames:
			return a.sprite_frames.get_frame_texture(a.animation, a.frame)
	return null

func apply_occlusion(sprite: GeometryInstance3D) -> void:
	if not occlusion_material:
		return
	var mat := occlusion_material.duplicate() as ShaderMaterial
	mat.set_shader_parameter("tex", get_sprite_texture(sprite))
	mat.set_shader_parameter("alpha_amount", 1.0)
	occluding[sprite] = { "original": sprite.material_override, "material": mat, "tween": null }
	sprite.material_override = mat
	tween_occlusion(sprite, occlusion_alpha, false)

func remove_occlusion(sprite: GeometryInstance3D) -> void:
	tween_occlusion(sprite, 1.0, true)

func tween_occlusion(sprite: GeometryInstance3D, target_alpha: float, restore_after: bool) -> void:
	if not occluding.has(sprite):
		return
	var data: Dictionary = occluding[sprite]
	var mat := data["material"] as ShaderMaterial
	if not mat:
		return

	# if a fade is already running, stop it before starting a new one
	if data["tween"]:
		(data["tween"] as Tween).kill()

	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/alpha_amount", target_alpha, fade_duration)

	if restore_after:
		# once faded back in, swap the occlusion material out for the original
		tween.tween_callback(restore_sprite.bind(sprite, data["original"]))

	data["tween"] = tween

func restore_sprite(sprite: GeometryInstance3D, original: Material) -> void:
	if is_instance_valid(sprite):
		sprite.material_override = original
	occluding.erase(sprite)
