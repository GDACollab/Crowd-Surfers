extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var bar_1: Control = $TextureProgressBar1
@onready var bar_2: Control = $TextureProgressBar2

const LOAD_SCENE: String = "res://Scenes/UI Menus/loading.tscn"
const MINIMUM_LOAD_SCENE_TIME: float = 0.35
const FADE_TIME: float = 0.75

var transitioning: bool = false

func _ready():
	self.visible = false
	#animation_player.speed_scale = 1 / FADE_TIME;

func transition_to_scene(finalScene: PackedScene):
	if (transitioning):
		return
	
	transitioning = true
	self.visible = true
	set_bar_random_angle()
	animation_player.play("fade_in")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 
	get_tree().paused = false

	# Change scenes to finalScene, wait while this happens
	get_tree().change_scene_to_packed(finalScene)
	await get_tree().scene_changed
	Settings.update_fmod_volumes()

	fade_out()

func transition_to_scene_with_loading(finalScene: String):
	if (transitioning):
		return
	
	transitioning = true
	self.visible = true
	set_bar_random_angle()
	animation_player.play("fade_in")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 
	get_tree().paused = false

	# Change scene to loading scene, wait while this happens
	get_tree().change_scene_to_packed(load(LOAD_SCENE))
	await get_tree().scene_changed
	# Enable this if/when loading screen gets sound
	Settings.update_fmod_volumes()
	
	set_bar_random_angle()
	animation_player.play("fade_out")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 
	
	ResourceLoader.load_threaded_request(finalScene)
	var progress: Array[float] = []
	var progressBar: TextureProgressBar = get_tree().current_scene.get_node("SynthProgressBar")
	while ResourceLoader.load_threaded_get_status(finalScene, progress) != ResourceLoader.THREAD_LOAD_LOADED:
		progressBar.value = lerp(progressBar.value, progress[0], get_process_delta_time())
		await get_tree().process_frame
	progressBar.value = 1.0

	var finalSceneLoaded: PackedScene = ResourceLoader.load_threaded_get(finalScene)
	
	await get_tree().create_timer(MINIMUM_LOAD_SCENE_TIME).timeout 
	
	set_bar_random_angle()
	animation_player.play("fade_in")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 
	
	# Change to final scene now that its loaded
	get_tree().change_scene_to_packed(finalSceneLoaded)
	await get_tree().scene_changed
	Settings.update_fmod_volumes()
	
	fade_out()

func fade_out():
	set_bar_random_angle()
	animation_player.play("fade_out")
	# Wait for animation
	await get_tree().create_timer(FADE_TIME).timeout 
	
	self.visible = false
	transitioning = false

func set_bar_random_angle():
	var rand = randf_range(4.0, 20.0)
	if (randf_range(0, 1.0) < 0.5):
		rand *= -1

	print(rand)
	
	bar_1.rotation = rand * PI / 180
	bar_2.rotation = rand * PI / 180
