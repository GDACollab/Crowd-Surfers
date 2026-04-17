class_name VoiceManager
extends Node

@export var typewriter_voice_frequency = 2

var character_voice = {
	"Slip": "andro",
	"Chef": "deep",
	"Sam": "deep"
}

func _handle_typewriter_voice(dialogue_text: String, character: String, letter_index: int, alphanumerics_count: int) -> bool:
	if (alphanumerics_count % typewriter_voice_frequency == 0):
		var should_increment_alphanumeric_counter = true
		var letter = dialogue_text[letter_index]
		# FmodServer.load_bank("bank:/CHAR", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
		# print("event exists") if FmodServer.check_event_path("event:/SFX/CHAR/typewriter_voice/typewriter_voice_hub") else print("event does not exist")
		var letter_sound = FmodServer.create_event_instance("event:/SFX/CHAR/typewriter_voice/typewriter_voice_hub")
		
		letter_sound.set_parameter_by_name_with_label("voice", character_voice[character], false)
		
		# regex match
		if (RegEx.create_from_string("[A-Za-z]").search(letter)): 
			letter_sound.set_parameter_by_name_with_label("letter", letter.to_lower(), false)
		
		elif (RegEx.create_from_string("[0-9]").search(letter)): 
			letter_sound.set_parameter_by_name_with_label("letter", letter, false)
			
		else:
			letter_sound.set_parameter_by_name_with_label("letter", "punc", false)
			should_increment_alphanumeric_counter = false
		
		letter_sound.start()
		return should_increment_alphanumeric_counter
		
	return true
