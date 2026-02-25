extends Control

@onready var scroll_con: ScrollContainer = $ScrollContainer

# When the debug menu is pressed, the menu pops up
func _on_debug_menu_button_pressed() -> void:
	scroll_con.visible = not scroll_con.visible
