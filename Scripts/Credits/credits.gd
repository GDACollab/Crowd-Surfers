extends Control
@onready var credits_text_container: VBoxContainer = $CreditsTextContainer

@export_category("Scroll Settings")
@export var slow_scroll_speed: float = 50.0
@export var fast_scroll_speed: float = 250.0
@export var scroll_speed_change_rate_per_second: float = 250.0

@export_category("Text Settings")
@export var separator_size: float = 40.0
@export var credits_starting_y: float = 700
@export var credits_text_file_string: String = ""
@export var credits_text_scene: PackedScene

@export_category("Images")
@export var images: Array[CreditsImageData]

#Used for a smooth transition between slow and fast scroll speeds
var current_scroll_speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		# Add label as a child
		credits_text_container.add_child(label)
		
	# Create images
	for i in images.size():
		var image: TextureRect = TextureRect.new()
		image.texture = images[i].image
		image.scale *= images[i].imageScale
		image.position = images[i].imagePosition
		self.add_child(image)
		
func _process(delta: float):
	if (Input.is_action_pressed("speed_up_credits") and current_scroll_speed < fast_scroll_speed):
		current_scroll_speed += scroll_speed_change_rate_per_second * delta
	elif (!Input.is_action_pressed("speed_up_credits") and current_scroll_speed > slow_scroll_speed):
		current_scroll_speed -= scroll_speed_change_rate_per_second * delta
	self.position.y += current_scroll_speed * -1 * delta
	# This apparently refreshes godot's hover detection. Without it, when the credits text moves upwards
	#godot still thinks you are hovering over it
	Input.warp_mouse(get_viewport().get_mouse_position())
