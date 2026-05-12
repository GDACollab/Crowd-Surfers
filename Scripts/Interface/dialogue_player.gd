extends Node
class_name DialoguePlayer

@export var story : InkStory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("[STORY] Playing dialogue before scene: " + Story.next_scene)
	#This is all you need to do in order to play dialogue! Swag!
	Inky.SetNewStory(story)
	var current_knot = Story.get_current_knot()
	if(current_knot != ""):
		Inky.PlayStoryFromKnot(current_knot)
		Inky.DialogueEnded.connect(_on_dialogue_end)
	else:
		get_tree().change_scene_to_file(Story.next_scene)

func _on_dialogue_end():
	if(Story.next_scene):
		SceneFadeTransition.transition_to_scene_with_loading(Story.next_scene)
