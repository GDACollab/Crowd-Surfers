extends Node
class_name DialoguePlayer

@export var story : InkStory
var current_knot := ""

func _init() -> void:
	Inky.DialogueEnded.connect(_on_dialogue_end)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("[STORY] Playing dialogue before scene: " + Story.next_scene)
	#This is all you need to do in order to play dialogue! Swag!
	Inky.SetNewStory(story)
	current_knot = Story.get_current_knot()
	if(current_knot != ""):
		Inky.PlayStoryFromKnot(current_knot)
	else:
		get_tree().change_scene_to_file(Story.next_scene)

func _on_dialogue_end():
	SaveDataManager.save_data()
	if(Story.next_scene):
		if(current_knot == "main_act3_scene2"):
			SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/UI Menus/Credits/credits.tscn")
		SceneFadeTransition.transition_to_scene_with_loading(Story.next_scene)
