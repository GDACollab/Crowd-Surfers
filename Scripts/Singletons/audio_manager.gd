extends Node2D
class_name AudioManager

## Public registry that (ideally) contains all persitent FMOD events (music, looping SFX, etc)
@export var registry: Dictionary
var TITLE_SCREEN_PULSING := false
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
	# kill_duplicate_persistents("event:/MUS/title")
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

## Takes a key, takes an FMOD event path, and returns a newly created event instance.
## Also takes a `killOnSceneChange` boolean that determines whether or not to stop and release the instance upon a scene change.
## The key, instance, path, and `killOnSceneChange` are then mapped to `registry`.
func create_persistent(key: String, eventPath: String, killOnSceneChange := false) -> FmodEvent:
	var eventInstance = FmodServer.create_event_instance(eventPath)

	registry[key] = {
		"instance": eventInstance,
		"path": eventPath,
		"killOnSceneChange": killOnSceneChange,
		"pausePosition": -1
		}
		
	return eventInstance
	
## Takes a key and pauses the instance belonging to it, storing the playback position in memory.
## Returns true upon success, false upon failure (key not found or instance is already paused)
## The FmodEvent `paused` property does not account for fade outs, which is why this function is necessary.
func pause_persistent(key: String) -> bool:
	if (registry.has(key) and registry[key]["pausePosition"] == -1):
		var eventInstance = registry[key]["instance"]
		registry[key]["pausePosition"] = eventInstance.position
		eventInstance.stop(FmodServer.FMOD_STUDIO_STOP_ALLOWFADEOUT)
		print("AudioManager: Paused instance of \"" + str(key) + "\"")
		return true
	
	print("AudioManager: Failed to pause \"" + str(key) + "\"")
	return false

## Takes a key and unpauses the instance belonging to it.
## Returns true upon success, false upon failure (key not found or instance is not paused)
func unpause_persistent(key: String) -> bool:
	if (registry.has(key) and registry[key]["pausePosition"] != -1):
		var eventInstance = registry[key]["instance"]
		eventInstance.set_timeline_position(registry[key]["pausePosition"])
		eventInstance.start()
		registry[key]["pausePosition"] = -1
		print("AudioManager: Unpaused instance of \"" + str(key) + "\"")
		return true
		
	print("AudioManager: Failed to unpause \"" + str(key) + "\"")
	return false
	
## Takes a registry key, stops and releases the associated event instance, and removes it from the registry.
## Returns true if the item was successfully removed, false if any not.
func kill_persistent(key: String) -> bool:
	var returnCode = false
		
	if (registry.has(key)):
		registry[key]["instance"].stop(FmodServer.FMOD_STUDIO_STOP_ALLOWFADEOUT)
		registry[key]["instance"].release()
		print("AudioManager: Killed instance of \"" + str(key) + "\"")
		return registry.erase(key)
		
	return returnCode
	
## Takes registry keys, stops and releases the all associated event instances, and removes them from the registry.
## Returns true if ALL items were successfully removed, false if any were not.
func kill_persistents(keys: Array[String]) -> bool:
	var returnCode = true
	
	for k in keys:
		returnCode = returnCode && kill_persistent(k)
		
	return returnCode
	
## Destroys ALL instances sharing the given path.
## Returns true if ALL items were successfully removed, false if any were not.
func kill_duplicate_persistents(eventPath: String) -> bool:
	var returnCode = true
	
	for iterKey in registry.keys():
		var currVal = registry[iterKey]
		
		if (currVal["path"] == eventPath):
			currVal["instance"].stop(FmodServer.FMOD_STUDIO_STOP_ALLOWFADEOUT)
			currVal["instance"].release()
			print("AudioManager: Killed instance of \"" + str(iterKey) + "\"")
			returnCode = returnCode && registry.erase(iterKey)
		
		else:
			returnCode = false
			
	return returnCode
	
## Takes registry keys, stops and releases the all associated event instances, and removes them from the registry.
## Returns true if ALL items were successfully removed, false if any were not.
func kill_all_persistents() -> bool:
	return kill_persistents(registry.keys())
	
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
	
func search_registry_by_path(eventPath: String) -> Array[FmodEvent]:
	var instances : Array[FmodEvent]
	
	for iterKey in registry.keys():
		var currVal = registry[iterKey]
		
		if (currVal["path"].contains(eventPath)):
			instances.append(currVal["instance"])
			
	return instances

## Returns true if 1 or multiple instances of a given event path exists in registry.
func path_exists_in_registry(eventPath: String) -> bool:
	var returnCode = false
	
	for val in registry.values():
		returnCode = returnCode || (val["path"] == eventPath)
		if returnCode: return returnCode
		
	return returnCode
