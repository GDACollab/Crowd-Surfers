extends Control

@onready var scroll_con: ScrollContainer = $ScrollContainer

# When the debug menu is pressed, the menu pops up
func _on_debug_menu_button_pressed() -> void:
	scroll_con.visible = not scroll_con.visible
	
func _process(_delta: float) -> void:
	var parent = get_parent()
	if (get_index() < parent.get_child_count()):
		move_to_front()
