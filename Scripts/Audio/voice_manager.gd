class_name VoiceManager
extends Node

## Determines how often a character voice sound plays (every 1, 2, 3, etc. letters)
@export var typewriter_voice_frequency : int = 2

## TODO: deprecate this dictionary and change FMOD voice parameter values to character names rather than voice archetypes
var character_voice : Dictionary = {
	"default": "default",
	"Chef": "deep",
	"Minny": "deep",
	"Nyx": "andro",
	"Pavo": "andro"
}

func _handle_typewriter_voice(dialogue_text: String, character: String, letter_index: int, alphanumerics_count: int, textSpeedScale: float) -> bool:
	## `typewriter_voice_frequency` scaled respective to text speed
	var typewriter_voice_frequency_scaled = floor(typewriter_voice_frequency * textSpeedScale) as int
	
	if (alphanumerics_count % typewriter_voice_frequency_scaled == 0):
		var should_increment_alphanumeric_counter = true
		var letter = dialogue_text[letter_index]
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
