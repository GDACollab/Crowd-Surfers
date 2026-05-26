extends Control

## Proper names for voicemail entries
var voicemail_directory := {
	"main_act1_scene2_voicemail" : "Pavo Act 1",
	"Pavo_act2_voicemail" : "Pavo Act 2",
	"Pavo_act3_voicemail" : "Pavo Act 3",
	"main_act2_scene2_voicemail" : "Nyx Act 1",
	"Nyx_act2_voicemail" : "Nyx Act 2",
	"Nyx_act3_voicemail" : "Nyx Act 3",
	"Minny_act2_voicemail" : "Minny Act 2",
	"Minny_act3_voicemail" : "Minny Act 3",
}

## TODO: Currently plays a random voicemail, will eventually have to pull up a list of available scenes
func _on_voicemail_1_button_pressed() -> void:
	## Just plays a random voicemail if any are available
	if(Story.voicemail_history.size() > 0):
		var new_voicemail = Story.voicemail_history.pick_random()
		print("[DIALOGUE] Playing voicemail for: ", voicemail_directory[new_voicemail])
		Inky.PlayStoryFromKnot(new_voicemail)
