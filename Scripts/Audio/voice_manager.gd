extends Node
@export var typewriter_voice_frequency = 2

var character_voice = {
	"Slip": "andro",
	"Chef": "deep",
	"Sam": "deep"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass

func _handle_typewriter_voice(dialogue_text: String, character: String, letter_index: int, alphanumerics_count: int) -> bool:
	if (alphanumerics_count % typewriter_voice_frequency == 0):
		var should_increment_alphanumeric_counter = true
		var letter = dialogue_text[letter_index]
		var letter_sound = FmodServer.create_event_instance("event:/SFX/CHAR/animalese/DialogueTest")
		
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
		
	return false
