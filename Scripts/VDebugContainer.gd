extends VBoxContainer

var scenes = DirAccess.open("res://Scenes/Levels/")
var DebugSingleDisplay : PackedScene = preload("res://Scenes/Debug Menu/DebugSingleDisplay.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# loop through the "res://Scenes/Levels/" folder
	scenes.list_dir_begin()
	var scene_name = scenes.get_next()
	while scene_name != "":
		# for each scene add a new button to the menu.
		var new_level = DebugSingleDisplay.instantiate()
		new_level.scene_name = scene_name
		add_child(new_level)
		scene_name = scenes.get_next()
	pass # Replace with function body.
