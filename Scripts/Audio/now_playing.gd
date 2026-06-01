extends Control

# ts jank as hell

@export var track_label_text : String 
@export var manual_x_position_offset : int
@export var hold_time := 4.0
@export_enum("Left", "Right") var text_alignment := "Right"
@export_enum("Top", "Bottom") var enter_position := "Top"

@onready var animation_player := $AnimationPlayer
@onready var container := $NPContainer
@onready var track_label := $NPContainer/LabelBackground/TrackLabel
#@onready var track_label_background := $NPContainer/LabelBackground
#@onready var loading_disc_sprite := $NPContainer/LoadingDisc

func _ready() -> void:
	# play_banner_animation()
	
	print("enter_position: " + str(enter_position))
	
	track_label.text = "[i]" + track_label_text
	
	var font: Font = track_label.get_theme_font("italics_font")	
	var font_size: Vector2 = font.get_string_size("[i]" + track_label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, track_label.get_theme_font_size("font_size"))
	
	if (text_alignment == "Right"):
		container.position.x -= font_size.x
	else:
		container.position.x += font_size.x
		
	container.position.x += manual_x_position_offset

func _exit_tree() -> void:
	var banner_animation = animation_player.get_animation("banner")
	
	# For some reason this change to the animation persists between scenes, need to reset upon unloading
	if (enter_position == "Bottom"):
		container.position.y = container.position.y * -1
			
		for i in range(0, banner_animation.track_get_key_count(0)):
			var curr_key_value = banner_animation.track_get_key_value(0, i)
			banner_animation.track_set_key_value(0, i, curr_key_value * -1)

func play_banner_animation():
	var banner_animation = animation_player.get_animation("banner")
	banner_animation.track_set_key_time(0, 2, 0.5 + hold_time)
	banner_animation.track_set_key_time(0, 3, 1.0 + hold_time)
	
	if (enter_position == "Bottom"):
		container.position.y = container.position.y * -1
		
		for i in range(0, banner_animation.track_get_key_count(0)):
			var curr_key_value = banner_animation.track_get_key_value(0, i)
			banner_animation.track_set_key_value(0, i, curr_key_value * -1)
	
	await get_tree().create_timer(1).timeout # Wait for the scene change animation to finish
	
	animation_player.play("banner")
