extends Node3D
@onready var hud := get_node("Hud")
@onready var level_end := get_node("LevelEndCollider")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Provide the end level collider to the HUD so it can calculate the player's progress
	if(level_end):
		hud.level_end_pos = Vector2(level_end.position.x, level_end.position.z)
		hud.has_level_end_pos = true
	else:
		print("Error: Could not find a node in scene tree \"LevelEndCollider\"")
