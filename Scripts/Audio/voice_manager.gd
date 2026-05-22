class_name VoiceManager
extends Node

## Determines how often a character voice sound plays (every 1, 2, 3, etc. letters)
@export var typewriter_voice_frequency := 2

const PUNCTUATION_PITCHES := {
	"?": 1.0,
	".": -1.0,
	"!": 0.5
}

var punctuation_regexes := {
	"?": RegEx.create_from_string("[?]+"),
	".": RegEx.create_from_string("[.]+"),
	"!": RegEx.create_from_string("[!]+")
}

var letter_regex := RegEx.create_from_string("[A-Za-z]")

func _handle_typewriter(dialogue_text: String, character: String, letter_index: int, alphanumerics_count: int, textSpeedScale: float) -> bool:
	var frequency_scaled := floor(typewriter_voice_frequency * textSpeedScale) as int
	
	if alphanumerics_count % frequency_scaled != 0:
		return true
	
	var should_increment := true
	var letter := dialogue_text[letter_index]
	var letter_sound := FmodServer.create_event_instance("event:/SFX/CHAR/voiceover/typewriter/vo_typewriter_hub")

	letter_sound.set_parameter_by_name_with_label("voice", character.to_lower(), false)

	if letter_regex.search(letter): 
		letter_sound.set_parameter_by_name_with_label("letter", letter.to_lower(), false )
	else: 
		letter_sound.set_parameter_by_name_with_label("letter", "punc", false )
		should_increment = false
	
	# Nearby punctuation pitch influence
	for punctuation in punctuation_regexes:
		var regex: RegEx = punctuation_regexes[punctuation]
		var pitch: float = PUNCTUATION_PITCHES[punctuation]
		
		var matches = regex.search_all(dialogue_text, letter_index)
		
		for match in matches:
			var match_start := match.get_start()
			
			if (letter_index >= (match_start - 4)) and (letter_index < match_start): 
				letter_sound.set_parameter_by_name("letter_pitch", pitch)
				break
	
	letter_sound.start()
	
	return should_increment

func _handle_voiceover():
	pass
