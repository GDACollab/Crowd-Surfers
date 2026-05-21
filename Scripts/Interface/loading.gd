extends Control

var loading_crackle: FmodEvent

func _enter_tree() -> void:
	loading_crackle = Audio.create_persistent("loading_crackle", "event:/SFX/UI/menu_loading")
	loading_crackle.start()
	
func _exit_tree() -> void:
	Audio.kill_persistent("loading_crackle")
