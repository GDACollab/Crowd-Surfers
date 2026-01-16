extends VBoxContainer

var scenes = DirAccess.open("res://Scenes/")
var DebugSingleDisplay : PackedScene = preload("res://DebugSingleDisplay.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scenes.list_dir_begin()
	var scene_name = scenes.get_next()
	while scene_name != "":
		var new_level = DebugSingleDisplay.instantiate()
		new_level.scene_name = scene_name
		add_child(new_level)
		scene_name = scenes.get_next()
	pass # Replace with function body.
