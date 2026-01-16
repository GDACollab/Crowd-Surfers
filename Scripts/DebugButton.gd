extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# When the debug menu is pressed, the menu pops up
func _on_debug_menu_button_pressed() -> void:
	if (get_node("ScrollContainer").is_visible()): get_node("ScrollContainer").visible = false
	elif (!get_node("ScrollContainer").is_visible()): get_node("ScrollContainer").visible = true
	pass # Replace with function body.
