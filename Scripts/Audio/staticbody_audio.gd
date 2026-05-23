extends Node3D

@export var trigger_distance: float = 5.0
@export var player_path: NodePath

var player: CharacterBody3D
var parent_body: StaticBody3D
var is_player_near := false

func _ready():
	player = get_node(player_path)
	parent_body = get_parent() as StaticBody3D

func _process(_delta):
	if player == null or parent_body == null:
		return

	var distance = player.global_position.distance_to(
		parent_body.global_position
	)

	var currently_near = distance <= trigger_distance

	# Entered radius
	if currently_near and not is_player_near:
		is_player_near = true
		on_player_enter_radius()

	# Left radius
	elif not currently_near and is_player_near:
		is_player_near = false
		on_player_exit_radius()


func on_player_enter_radius():
	print("Player entered radius")


func on_player_exit_radius():
	print("Player left radius")
