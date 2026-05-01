@tool
extends EditorScript

const TARGET_SCRIPT = preload("res://Scripts/automated_asset_type_3D_object.gd")

func _run() -> void:
	var total_nodes = 0
	for path in get_editor_interface().get_open_scenes():
		get_editor_interface().open_scene_from_path(path)
		var root = get_editor_interface().get_edited_scene_root()
		if not root:
			continue
		for node in _find_nodes_with_script(root, TARGET_SCRIPT):
			node.active = true
			total_nodes += 1
		get_editor_interface().save_scene()
	print("Set %d nodes to active = true." % total_nodes)

func _find_nodes_with_script(node: Node, script: Script) -> Array[Node]:
	var result: Array[Node] = []
	if node.get_script() == script:
		result.append(node)
	for child in node.get_children():
		result.append_array(_find_nodes_with_script(child, script))
	return result
