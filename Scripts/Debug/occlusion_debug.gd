extends Label

var my_parent : Node

func _enter_tree() -> void:
	my_parent = get_parent()
	if(my_parent is not SlipCamera):
		push_error("Debug label must be child of SlipCamera")
		queue_free()

func _process(delta: float) -> void:
	var display_text := "OCCLUDING:"
	for o in my_parent.occluding:
		display_text += "\n" + str(o)
	text = display_text
