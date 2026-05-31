extends Control

@export var continue_label_text : String 

@onready var animator := $AnimationPlayer
@onready var container := $NPContainer
@onready var continue_label := $NPContainer/ContinueLabel
@onready var continue_label_backing := $NPContainer/ContinueLabelBacking
@onready var loading_disc_sprite := $NPContainer/LoadingDisc

func _ready() -> void:
	play_banner_animation()
	continue_label.text = continue_label_text
	
	# Really dumb implementation with arbitrary constants that don't work. how do i make this work :sob:
	# I tried doing an HBoxContainer thing but my whole implementation got fucked up so idk if what this is doing is even comprehensible
	continue_label_backing.scale.x += continue_label.get_total_character_count() * 0.0175
	loading_disc_sprite.position.x += continue_label.get_total_character_count() * 12

func play_banner_animation():
	animator.play("banner")
