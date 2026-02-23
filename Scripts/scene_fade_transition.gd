extends Node

const LOAD_SCENE: String = "res://Scenes/UI Menus/loading.tscn"
const MINIMUM_LOAD_SCENE_TIME: float = 1.0
const FADE_TIME: float = 1.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var transitioning: bool = false

func _ready():
	self.visible = false
	animation_player.speed_scale = 1 / FADE_TIME;

func transition_to_scene(finalScene: PackedScene):
	if (transitioning):
		return
	
	transitioning = true
	self.visible = true
	animation_player.play("fade_in")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 

	# Change scenes to finalScene, wait while this happens
	get_tree().change_scene_to_packed(finalScene)
	await get_tree().scene_changed

	animation_player.play("fade_out")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 
	
	self.visible = false
	transitioning = false

func transition_to_scene_with_loading(finalScene: String):
	if (transitioning):
		return
	
	transitioning = true
	self.visible = true
	animation_player.play("fade_in")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 

	# Change scene to loading scene, wait while this happens
	get_tree().change_scene_to_packed(load(LOAD_SCENE))
	await get_tree().scene_changed
	
	animation_player.play("fade_out")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 
	
	ResourceLoader.load_threaded_request(finalScene)
	while ResourceLoader.load_threaded_get_status(finalScene) != ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().process_frame
		
	var finalSceneLoaded: PackedScene = ResourceLoader.load_threaded_get(finalScene)
	
	await get_tree().create_timer(MINIMUM_LOAD_SCENE_TIME).timeout 
	
	animation_player.play("fade_in")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 
	
	# Change to final scene now that its loaded
	get_tree().change_scene_to_packed(finalSceneLoaded)
	await get_tree().scene_changed
	
	animation_player.play("fade_out")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 
	
	self.visible = false
	transitioning = false
