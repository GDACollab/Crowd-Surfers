extends Node
class_name StoryTracker

var debug_mode := true

## Serialized
var main_story_progress := 0
var main_story_complete := false
var story_arcs_progress := [
	0,
	0,
	0
]

var level_character := [
	"Pavo",
	"Minny",
	"Nyx"
]
var selected_level : int = 0
var post_level := false
var next_scene : String
var voicemail_history : Array[String]

func _ready() -> void:
	get_story_progress_info()

func increase_main_story_progress():
	if(main_story_progress == 2):
		main_story_complete = true
	else:
		main_story_progress += 1

func get_main_story_progress():
	return main_story_progress

## The big filter
func get_current_knot() -> String:
	get_story_progress_info()
	var knot_name := ""
	var current_act := 0
	## Replay Mode scene
	if(main_story_complete):
		if(post_level):
			post_level = false
			current_act = story_arcs_progress[selected_level]
			## Increment to next scene
			if(story_arcs_progress[selected_level] < 1):
				story_arcs_progress[selected_level] += 1
			knot_name = level_character[selected_level] + "_act" + str(current_act + 1)
		else:
			return ""
	## Main Story scene
	else:
		if(main_story_progress > selected_level):
			print("Seen already")
			return ""
		current_act = selected_level
		if(post_level):
			post_level = false
			knot_name = "main_act" + str(main_story_progress + 1) + "_scene2"
			increase_main_story_progress()
		else:
			knot_name = "main_act" + str(main_story_progress + 1) + "_scene1"
	print(knot_name)
	return knot_name

func get_story_progress_info():
	print(
		"Main Story Progress: " + str(main_story_progress) +
		"\nPavo Progress: " + str(story_arcs_progress[0]) +
		"\nMinny Progress: " + str(story_arcs_progress[1]) +
		"\nNyx Progress: " + str(story_arcs_progress[2])
	)
	serialize_story()

func load_story(progress_dict : Dictionary):
	main_story_progress = progress_dict["main_story_progress"]
	main_story_complete = progress_dict["story_complete"]
	var side_progress : Dictionary = progress_dict["side_story_progress"]
	if(side_progress):
		var iter := 0
		for i in side_progress:
			story_arcs_progress[iter] = side_progress[level_character[iter]]
			iter += 1

func serialize_story() -> Dictionary:
	var story_data := {}
	story_data["main_story_progress"] = main_story_progress
	story_data["story_complete"] = main_story_complete
	
	var side_story_progress := {}
	var iter := 0
	for i in story_arcs_progress:
		side_story_progress[level_character[iter]] = i
		iter += 1
	story_data["side_story_progress"] = side_story_progress
	print(story_data)
	return story_data
