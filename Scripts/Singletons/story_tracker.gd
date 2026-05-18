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

func increase_main_story_progress():
	if(main_story_progress == 2):
		main_story_complete = true
	else:
		main_story_progress += 1

func get_main_story_progress():
	return main_story_progress

## The big filter
func get_current_knot() -> String:
	var knot_name := ""
	var current_act := 0
	## Replay Mode scene
	if(main_story_complete):
		## Replay mode never plays scenes pre-level
		if(!post_level):
			print("[STORY] Entering level in replay mode")
			return ""
		post_level = false
		current_act = story_arcs_progress[selected_level]
		## Increment to next scene
		if(story_arcs_progress[selected_level] < 1):
			story_arcs_progress[selected_level] += 1
		knot_name = level_character[selected_level] + "_act" + str(current_act + 2)
		_add_voicemail(knot_name)
	## Main Story scene
	else:
		## Check if player is playing current story level
		if(main_story_progress != selected_level):
			print("[STORY] Seen already")
			return ""
		if(post_level):
			post_level = false
			knot_name = "main_act" + str(main_story_progress + 1) + "_scene2"
			## Last story act doesn't have a voicemail
			if(main_story_progress < 2):
				_add_voicemail(knot_name)
			increase_main_story_progress()
		else:
			knot_name = "main_act" + str(main_story_progress + 1) + "_scene1"
	print("[STORY] Playing: ",knot_name)
	return knot_name

func _add_voicemail(knot_name : String):
	var voicemail_name = knot_name + "_voicemail"
	if(!voicemail_history.has(voicemail_name)):
		voicemail_history.append(voicemail_name)

func get_story_progress_info():
	print(
		"[STORY PROGRESS]\nMain Story Progress: " + str(main_story_progress) +
		"\nReplay Mode: " + str(main_story_complete),
		"\nPavo Progress: " + str(story_arcs_progress[0]) +
		"\nMinny Progress: " + str(story_arcs_progress[1]) +
		"\nNyx Progress: " + str(story_arcs_progress[2])
	)

func load_story(progress_dict : Dictionary):
	main_story_progress = progress_dict["main_story_progress"]
	main_story_complete = progress_dict["story_complete"]
	var side_progress : Dictionary = progress_dict["side_story_progress"]
	if(side_progress):
		var iter := 0
		for i in side_progress:
			story_arcs_progress[iter] = side_progress[level_character[iter]]
			iter += 1
	if(progress_dict.has("voicemail_history")):
		voicemail_history = progress_dict["voicemail_history"]
	get_story_progress_info()

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
	
	story_data["voicemail_history"] = voicemail_history
	return story_data

func reset_story():
	main_story_progress = 0
	main_story_complete = false
	for s in story_arcs_progress:
		s = 0
