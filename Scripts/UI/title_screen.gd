extends Control

@onready var title_image: TextureRect = $Images/TitleImage
@onready var now_playing_image: TextureRect = $Images/NowPlaying
@onready var play_button: TextureButton = $PlayButton
@onready var credits_button: TextureButton = $CreditsButton
@onready var bottom_glow: TextureRect = $BottomGlow
# @onready var music_bpm: float = 90.

@export var music_notes: Array[TextureRect]
@export var music_notes_move_distance: float = 15
@export var hover_time: float = 4.0
@export var hover_magnitude: float = 1.0
@export var glow_max_alpha: float = 0.5
@export var button_scale_amount: float = 1.1

var title_image_start_y: float
var now_playing_image_start_y: float
var play_button_start_y: float
var credits_button_start_y: float
var timer: float
var move_up: int = -1
var title_music: FmodEvent

func _ready():
	title_image_start_y = title_image.position.y
	now_playing_image_start_y = now_playing_image.position.y
	play_button_start_y = play_button.position.y
	credits_button_start_y = credits_button.position.y
	
	var index: int = 0
	for note: TextureRect in music_notes:
		if (index % 2 == 1):
			note.position.y += music_notes_move_distance
		index += 1
	
	if (!Audio.registry.has("mus_title")):
		title_music = Audio.create_persistent("mus_title", "event:/MUS/title")
		title_music.set_callback(Callable(self, "_handle_beat_events"), FmodServer.FMOD_STUDIO_EVENT_CALLBACK_ALL)
		title_music.start()
		
	else:
		title_music = Audio.get_persistent_instance("mus_title")
		title_music.set_parameter_by_name("muffling", 0.)

func _process(delta: float):	
	title_image.position.y = sin((timer * 2 * PI) / hover_time) * hover_magnitude + title_image_start_y
	now_playing_image.position.y = sin(5 + (timer * 1.7 * PI) / hover_time) * hover_magnitude + now_playing_image_start_y
	play_button.position.y = sin(10 + (timer * 1.8 * PI) / hover_time) * hover_magnitude * 0.8 + play_button_start_y
	credits_button.position.y = sin(15 + (timer * 1.6 * PI) / hover_time) * hover_magnitude * 0.8 + credits_button_start_y
	
	bottom_glow.modulate.a -= delta;
	
	play_button.scale = play_button.scale.lerp(Vector2.ONE, delta)
	credits_button.scale = credits_button.scale.lerp(Vector2.ONE, delta)
	now_playing_image.scale = now_playing_image.scale.lerp(Vector2.ONE, delta)

	timer += delta

## FMOD event callback trigger, occurs every beat based on the event's desginated tempo
func _handle_beat_events(_dict: Dictionary, type: int) -> void: 
	if type == FmodServer.FMOD_STUDIO_EVENT_CALLBACK_TIMELINE_BEAT:
		_animate_to_beat()

func _animate_to_beat() -> void:
	var index: int = 0
	for note: TextureRect in music_notes:
		note.position.y += move_up * music_notes_move_distance * float(((index % 2) * 2) - 1)
		index += 1
		
	play_button.scale = Vector2.ONE * button_scale_amount
	credits_button.scale = Vector2.ONE * button_scale_amount
	now_playing_image.scale = Vector2.ONE * button_scale_amount * 0.95

	# Every other beat
	if (move_up == 1):
		bottom_glow.modulate.a = glow_max_alpha
		
	move_up *= -1

func _on_credits_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/Credits/credits.tscn"))
	title_music.set_parameter_by_name("muffling", 1.)
	# Audio.kill_persistent("mus_title")

func _on_play_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/MainMenu/MainMenu.tscn"))
	# title_music.set_parameter_by_name("muffling", 1.)
	Audio.kill_persistent("mus_title")
