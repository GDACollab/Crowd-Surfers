extends TextureRect

var scene_name : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	(get_node("DebugSceneName")).text = scene_name.trim_suffix(".tscn")
	pass # Replace with function body.

#changes scene when the associated button is clicked
func _on_debug_scene_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/" + scene_name)
	pass # Replace with function body.
