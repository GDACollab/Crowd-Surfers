extends Node
class_name ProgrammerAudioManager

var callable : Callable = Callable(self, "beat_callback")
var instance : FmodEvent

func _ready() -> void:
	instance = FmodServer.create_event_instance("event:/MUS/level_1")
	instance.start()
	instance.set_callback(callable, FmodServer.FMOD_STUDIO_EVENT_CALLBACK_TIMELINE_BEAT)
	
func beat_callback(args):
	if args.properties.beat:
		print("beat!")

# danny
# Sam
# zeuz
# Elliot
# Zachary
# marlo



# Marlowe Nash
# IYKYK
# Mind Binding

# Sam
# Gotta Move

# Zeuz
# Cooked Mid-Zoom

# Elliot
# crowd surfers test

# Danny
# Nightrush
