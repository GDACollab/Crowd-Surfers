extends Control

@export var voicemail_button_scene: PackedScene

@onready var ui_audio: Node2D = $UIAudio
@onready var voicemail_container: VBoxContainer = $VoicemailsBody/ScrollContainer/VoicemailVBoxContainer
@onready var no_voicemails_text: RichTextLabel = $VoicemailsBody/NoVoicemailsText

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

func _ready() -> void:
	for voicemail: String in Story.voicemail_history:
		var voicemail_button: TextureButton = voicemail_button_scene.instantiate()
		voicemail_button.get_child(0).text = "[i]" + voicemail_directory[voicemail]
		voicemail_container.add_child(voicemail_button)
		voicemail_button.pressed.connect(_on_voicemail_button_pressed.bind(voicemail_button))
		ui_audio.connect_confirm_button(voicemail_button)
		
	if (Story.voicemail_history.size() > 0):
		no_voicemails_text.visible = false
	else:
		no_voicemails_text.visible = true

func _on_voicemail_button_pressed(button: TextureButton) -> void:
	var raw_voicemail: String = voicemail_directory.find_key(button.get_child(0).text.substr(3))
	print(raw_voicemail)
		
	Inky.PlayStoryFromKnot(raw_voicemail)
