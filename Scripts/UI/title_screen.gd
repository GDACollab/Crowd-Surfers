extends Control

@onready var title_image: TextureRect = $Images/TitleImage
@onready var now_playing_image: TextureRect = $Images/NowPlaying
@onready var play_button: TextureButton = $PlayButton
@onready var credits_button: TextureButton = $CreditsButton

@export var music_notes: Array[TextureRect]
@export var music_notes_move_time: float = 0.5
@export var music_notes_move_distance: float = 15
@export var hover_time: float = 4.0
@export var hover_magnitude: float = 1.0

var title_image_start_y: float
var now_playing_image_start_y: float
var play_button_start_y: float
var credits_button_start_y: float
var timer: float
var move_up: int = -1

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

func _process(delta: float):	
	title_image.position.y = sin((timer * 2 * PI) / hover_time) * hover_magnitude + title_image_start_y
	now_playing_image.position.y = sin(5 + (timer * 1.7 * PI) / hover_time) * hover_magnitude + now_playing_image_start_y
	play_button.position.y = sin(10 + (timer * 1.8 * PI) / hover_time) * hover_magnitude * 0.8 + play_button_start_y
	credits_button.position.y = sin(15 + (timer * 1.6 * PI) / hover_time) * hover_magnitude * 0.8 + credits_button_start_y
	
	if (floor((timer + delta) / music_notes_move_time) > floor((timer) / music_notes_move_time)):
		# Index offsets the animation for every other note
		var index: int = 0
		for note: TextureRect in music_notes:
			note.position.y += move_up * music_notes_move_distance * float(((index % 2) * 2) - 1)
			index += 1
			
		move_up *= -1
		
	timer += delta

	
	
func _on_credits_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/Credits/credits.tscn"))

func _on_play_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/MainMenu/MainMenu.tscn"))
