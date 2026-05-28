extends Control

@export var voicemail_button_scene: PackedScene

@onready var ui_audio: Node2D = $UIAudio
@onready var voicemail_container: VBoxContainer = $VoicemailsBody/ScrollContainer/VoicemailVBoxContainer
@onready var no_voicemails_text: RichTextLabel = $VoicemailsBody/NoVoicemailsText

## Proper names for voicemail entries
var voicemail_directory := {
	"main_act1_scene2_voicemail" : "PAVO ACT 1",
	"Pavo_act2_voicemail" : "PAVO ACT 2",
	"Pavo_act3_voicemail" : "PAVO ACT 3",
	"main_act2_scene2_voicemail" : "NYX ACT 1",
	"Nyx_act2_voicemail" : "NYX ACT 2",
	"Nyx_act3_voicemail" : "NYX ACT 3",
	"Minny_act2_voicemail" : "MINNY ACT 2",
	"Minny_act3_voicemail" : "MINNY ACT 3",
}

func _ready() -> void:
	for voicemail: String in Story.voicemail_history:
		var voicemail_button: TextureButton = voicemail_button_scene.instantiate()
		voicemail_button.get_child(0).text = "[i]" + voicemail_directory[voicemail]
		voicemail_container.add_child(voicemail_button)
		voicemail_button.pressed.connect(_on_voicemail_button_pressed.bind(voicemail_button))
		ui_audio.connect_confirm_button(voicemail_button)
	
	# Connect focus neighbors
	var buttons: Array[Node] = voicemail_container.get_children()
	for i: int in buttons.size():
		# Set focus neighbors
		if i > 0:
			buttons[i].focus_neighbor_top = buttons[i-1].get_path()
		if i < buttons.size()-1:
			buttons[i].focus_neighbor_bottom = buttons[i+1].get_path()
		
	if (Story.voicemail_history.size() > 0):
		no_voicemails_text.visible = false
	else:
		no_voicemails_text.visible = true

func _on_voicemail_button_pressed(button: TextureButton) -> void:
	var raw_voicemail: String = voicemail_directory.find_key(button.get_child(0).text.substr(3))
	print(raw_voicemail)
		
	Inky.PlayStoryFromKnot(raw_voicemail)
