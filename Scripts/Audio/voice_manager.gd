extends Node
@export var typewriter_voice_frequency = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _handle_typewriter_voice(dialogue_text: String, typewriter_voice_type: String, iter: int, alphanumerics_count: int) -> void:
	if (alphanumerics_count % typewriter_voice_frequency == 0):
		var c = dialogue_text[iter]
		var animalese_sound = FmodServer.create_event_instance("event:/SFX/CHAR/animalese/DialogueTest");
		
		animalese_sound.set_parameter_by_name_with_label("voice", typewriter_voice_type, false)
		
		# regex match
		if (RegEx.create_from_string("[A-Za-z]").search(c)): 
			animalese_sound.set_parameter_by_name_with_label("letter", c.to_lower(), false)
		
		elif (RegEx.create_from_string("[0-9]").search(c)): 
			animalese_sound.set_parameter_by_name_with_label("letter", c, false)
			
		else:
			animalese_sound.set_parameter_by_name_with_label("letter", "punc", false)
			alphanumerics_count -= 1
		
		animalese_sound.start()
