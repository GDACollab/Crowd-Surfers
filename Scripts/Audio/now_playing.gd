extends Control

@export var continue_label_text : String 

@onready var animation_player := $AnimationPlayer
@onready var container := $NPContainer
@onready var continue_label := $NPContainer/LabelBackground/ContinueLabel
#@onready var continue_label_background := $NPContainer/LabelBackground
#@onready var loading_disc_sprite := $NPContainer/LoadingDisc

func _ready() -> void:
	play_banner_animation()
	continue_label.text = "[i]" + continue_label_text
	
	var font: Font = continue_label.get_theme_font("italics_font")	
	var font_size: Vector2 = font.get_string_size("[i]" + continue_label_text, HORIZONTAL_ALIGNMENT_RIGHT, -1, continue_label.get_theme_font_size("font_size"))
	
	container.position.x -= font_size.x
	print(font_size)

func play_banner_animation():
	animation_player.play("banner")
