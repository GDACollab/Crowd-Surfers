extends Control

@onready var scroll_container = $ScrollContainer

# When the debug menu is pressed, the menu pops up
func _on_debug_menu_button_pressed() -> void:
	if (scroll_container.is_visible()): scroll_container.visible = false
	elif (scroll_container.is_visible()): scroll_container.visible = true
