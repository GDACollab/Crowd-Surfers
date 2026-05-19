extends Node2D
class_name AudioManager

## Public registry that (ideally) contains all persitent FMOD events (music, looping SFX, etc)
@export var registry: Dictionary

var previous_scene: Node = null

func _ready():
	print("AudioManager loaded")
	
	# create_persistent("mus_title", "event:/MUS/title")
	# create_persistent("asf", "event:/MUS/title")
	# create_persistent("asd", "event:/MUS/title")
	# create_persistent("asasgdfsgs", "event:/MUS/title")
	# create_persistent("asdada", "event:/MUS/title")
	# print(registry)
	# print("Exists in registry: " + str(path_exists_in_registry("event:/MUS/title")))
	# kill_all_persistent("event:/MUS/title")
	# print(registry)
	
# TODO: Replace with a version that doesn't check if the scene has changed every single frame
func _process(_delta):
	var current_scene = get_tree().current_scene

	if current_scene != previous_scene:
		if (previous_scene != null): 
			_on_scene_changed()
		
		previous_scene = current_scene

func _on_scene_changed():
	# Destroys all event instances with a true `killOnSceneChange` tag
	for iterKey in registry.keys():
		if (registry[iterKey]["killOnSceneChange"] == true):
			kill_persistent(iterKey)

## Takes an FMOD event path, takes a key, and returns a newly created event instance.
## Also takes a `killOnSceneChange` boolean that determines whether or not to stop and release the instance upon a scene change.
## The key, instance, path, and `killOnSceneChange` are then mapped to `registry`.
func create_persistent(key: String, eventPath: String, killOnSceneChange: bool = false) -> FmodEvent:
	var eventInstance = FmodServer.create_event_instance(eventPath)

	registry[key] = {
		"instance": eventInstance,
		"path": eventPath,
		"killOnSceneChange": killOnSceneChange}
		
	return eventInstance
	
## Takes a registry key, stops and releases the associated event instance, and removes it from the registry.
func kill_persistent(key: String) -> bool:
	var returnVal = false
		
	if (registry.has(key)):
		registry[key]["instance"].stop(FmodServer.FMOD_STUDIO_STOP_ALLOWFADEOUT)
		registry[key]["instance"].release()
		return registry.erase(key)
		
	return returnVal
	
# Safely get a persistent instance from a key
# Returns null if key/value pair not found
func get_persistent_instance(key: String) -> FmodEvent:
	if registry.has(key):
		return registry[key]["instance"]
		
	return null
	
# Safely get a persistent path from a key
# Returns empty if key/value pair not found
func get_persistent_path(key: String) -> String:
	if registry.has(key):
		return registry[key]["path"]
		
	return ""

## Destroys ALL instances sharing the given path.
## Returns true if ALL items were successfully removed, false if any were not.
func kill_all_persistent(eventPath: String) -> bool:
	var returnVal = true
	
	for iterKey in registry.keys():
		var currVal = registry[iterKey]
		
		if (currVal["path"] == eventPath):
			currVal["instance"].stop(FmodServer.FMOD_STUDIO_STOP_ALLOWFADEOUT)
			currVal["instance"].release()
			returnVal = returnVal && registry.erase(iterKey)
		
		else:
			returnVal = false
			
	return returnVal

## Returns true if 1 or multiple instances of a given event path exists in registry.
func path_exists_in_registry(eventPath: String) -> bool:
	var returnVal = false
	
	for val in registry.values():
		returnVal = returnVal || (val["path"] == eventPath)
		if returnVal: return returnVal
		
	return returnVal
