extends Node

##Save data currently supports 3 levels, if you want to add more levels to the 
##save data, just extend the array lengths, the save files should automatically adjust.
##reducing the array size however may result in a crash on startup

const SAVE_PATH = "user://savedata/data.save"

##level index is (level number - 1)
var levels_complete:Array[bool] = [false,false,false]
var level_times:Array[float] = [0.0,0.0,0.0]
##TBA when dialogues are added
#var dialogues_reached:Array = []

##If a save file exists, load it, otherwise create it
func _ready() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		load_data()
	else:
		save_data()

func save_data() -> void:
	var saved_data: Dictionary = {
		"levels": levels_complete,
		"times": level_times,
		"master_volume": Settings.master_volume,
		"music_volume": Settings.music_volume,
		"sfx_volume": Settings.sfx_volume,
		"story_progress" : Story.serialize_story()
	}
	var err:Error = store_file(saved_data, SAVE_PATH)
	if err != OK:
		push_error("Unable to save data: ", error_string(err))
	print("Save Data saved")

func load_data() -> void:
	var loaded_data: Dictionary = {}
	
	var err: Error = open_file(SAVE_PATH, loaded_data)
	if err != OK:
		push_error("Unable to load data: ", error_string(err))
	
	#copy over data, will result in an error if not copied like this
	for i in range(loaded_data["levels"].size()):
		levels_complete[i] = loaded_data["levels"][i]
	for i in range(loaded_data["times"].size()):
		level_times[i] = loaded_data["times"][i]
	Settings.master_volume = loaded_data["master_volume"]
	Settings.music_volume = loaded_data["music_volume"]
	Settings.sfx_volume = loaded_data["sfx_volume"]
	Settings.update_fmod_volumes()
	# Safety check
	if(loaded_data.has("story_progress")):
		Story.load_story(loaded_data.get("story_progress"))
	print("Save Data loaded")

func reset_data() -> void:
	levels_complete = [false,false,false]
	level_times = [0.0,0.0,0.0]
	Story.reset_story()
	save_data()

#######################
###  FILE HANDLING  ###
#######################

##Saves data
static func store_file(data:Dictionary, file_path: String):
	var result:Array = _open_file_for_write(file_path)
	var err:Error = result[0] as Error
	var file:FileAccess = result[1] as FileAccess
	
	#if we got an error return the error, otherwise save data
	if err != OK:
		return err;
	
	file.store_var(data, false)
	file.close()
	return OK

##Loads data
static func open_file(file_path: String, out_data: Dictionary) -> Error:
	#clears out_data data, will be overridden
	out_data.clear()
	
	var result:Array = _open_file_for_read(file_path)
	var err:Error = result[0] as Error
	var file:FileAccess = result[1] as FileAccess
	#if we got an error opening the file return the error
	if err != OK:
		return err
	
	var value:Variant = file.get_var(false)
	file.close()
	
	#return error if file data is not the right type
	if typeof(value) != TYPE_DICTIONARY:
		return ERR_INVALID_DATA
	
	#set out_data to the save data
	out_data.merge(value as Dictionary, true)
	return OK

##Opens and reads file, for loading
static func _open_file_for_read(path: String) -> Array:
	#if file doesnt exist return file not found error
	if not FileAccess.file_exists(path):
		return [ERR_FILE_NOT_FOUND, null]
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	#if file can't be read return access error
	if file == null:
		return [FileAccess.get_open_error(), null]
	
	return [OK, file]

##Opens and edits file, for saving
static func _open_file_for_write(file_path: String) -> Array:
	var err: Error = _check_and_create_directory(file_path)
	#if file wasn't accessible return error
	if err != OK:
		return [err, null]
	
	var file:FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	#if file doesn't properly open return error
	if file == null:
		return [FileAccess.get_open_error(), null]
		
	return [OK, file]

##Checks if save directory exists(where save files are stored), creates one if not and is able to
static func _check_and_create_directory(file_path: String) -> Error:
	var dir_path: String = file_path.get_base_dir()
	#if file exists we good
	if DirAccess.dir_exists_absolute(dir_path):
		return OK
	#if file doesn't exist and we can create we create it
	return DirAccess.make_dir_recursive_absolute(dir_path)
