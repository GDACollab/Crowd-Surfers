extends Control
@onready var credits_text_container: VBoxContainer = $CreditsTextContainer
# @onready var ui_audio: Node2D = self.get_parent().get_child(0)

@export_category("Scroll Settings")
@export var slow_scroll_speed: float = 50.0
@export var fast_scroll_speed: float = 250.0
@export var scroll_speed_change_rate_per_second: float = 250.0
@export var credits_end_y: float = -30996.725

@export_category("Text Settings")
@export var separator_size: float = 40.0
@export var credits_starting_y: float = 700
@export var credits_text_file_string: String = ""
@export var credits_text_scene: PackedScene

@export_category("Images")
@export var images: Array[CreditsImageData]

var title_music: FmodEvent

#Used for a smooth transition between slow and fast scroll speeds
var current_scroll_speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (!Audio.registry.has("mus_title")):
		title_music = Audio.create_persistent("mus_title", "event:/MUS/title")
		title_music.start()
	
	current_scroll_speed = slow_scroll_speed
	self.position.y = credits_starting_y
	
	var credits_file: FileAccess = FileAccess.open(credits_text_file_string, FileAccess.READ)
	
	# Skip guide lines (amazing code) (wow!)
	credits_file.get_line()
	credits_file.get_line()
	credits_file.get_line()
	credits_file.get_line()
	credits_file.get_line()
	
	while (not credits_file.eof_reached()):
		var text: String = credits_file.get_line()
		text = text.replace("[size", "[font_size")
		if (text.contains("[font_size")):
			text += "[/font_size]"
		# print(text)
		# More empty lines = more space between texts 
		if (text == "" or text == " "):
			var separator: Control = Control.new()
			separator.custom_minimum_size.y = separator_size
			credits_text_container.add_child(separator)
			continue
			
		# Create the label node set its text and other properties
		var label: RichTextLabel = credits_text_scene.instantiate()
		label.text = text
		
		if (text.contains("|||")):
			# this is the stupidest code ive ever made why is godot doing this to me
			var font: Font = label.get_theme_font("normal_font")
			
			var first_half_text: String = text.substr(text.find("]") + 1, text.find("|||") - text.find("]") - 1)
			var first_half_text_size: Vector2 = font.get_string_size(first_half_text, HORIZONTAL_ALIGNMENT_CENTER, -1, label.get_theme_font_size("font_size"))
			
			var second_half_text: String = text.substr(text.find("|||") + 3, text.find("[", text.find("|||") + 3) - (text.find("|||") + 3))
			var second_half_text_size: Vector2 = font.get_string_size(second_half_text, HORIZONTAL_ALIGNMENT_CENTER, -1, label.get_theme_font_size("font_size"))
			
			var move_distance: float = second_half_text_size.x - first_half_text_size.x
		
			#thin space character (U+2009)
			var space_size: Vector2 = font.get_string_size(" ", HORIZONTAL_ALIGNMENT_CENTER, -1, label.get_theme_font_size("font_size"))
			var num_spaces_to_add: int = floor(move_distance / space_size.x)
			
			if (num_spaces_to_add < 0):
				num_spaces_to_add *= -1
				for i in range(num_spaces_to_add):
					text = text.insert(text.find("[/font_size]"), " ")
			else:
				for i in range(num_spaces_to_add):
					text = text.insert(text.find("]") + 1, " ")
			label.text = text
			
		# Add label as a child
		credits_text_container.add_child(label)
		# ui_audio.credits_text_labels.append(label)
		
	# Create images
	for i in images.size():
		var image: TextureRect = TextureRect.new()
		image.texture = images[i].texture
		image.scale *= images[i].scale
		image.position = images[i].position
		self.add_child(image)
		
func _process(delta: float):
	if (Input.is_action_pressed("speed_up_credits") and current_scroll_speed < fast_scroll_speed):
		current_scroll_speed += scroll_speed_change_rate_per_second * delta
	elif (!Input.is_action_pressed("speed_up_credits") and current_scroll_speed > slow_scroll_speed):
		current_scroll_speed -= scroll_speed_change_rate_per_second * delta
	self.position.y += current_scroll_speed * -1 * delta
	
	if (Input.is_action_just_pressed("ui_back") || self.position.y < credits_end_y):
		_on_back_button_pressed()

func _on_back_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/TitleScreen.tscn"))
