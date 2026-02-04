extends Control
@onready var credits_text_container: VBoxContainer = $CreditsTextContainer

@export var scroll_speed: float = 5.0
@export var separator_size: float = 40.0
@export var credits_starting_y: float = 700

@export var credits_text_file_string: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position.y = credits_starting_y
	
	var credits_file: FileAccess = FileAccess.open(credits_text_file_string, FileAccess.READ)
	
	# Skip guide lines
	credits_file.get_line()
	credits_file.get_line()
	credits_file.get_line()
	credits_file.get_line()
	
	while (not credits_file.eof_reached()):
		# Text file must be exactly this format of lines: text, size
		var text: String = credits_file.get_line()
		print(text)
		# More empty lines = more space between texts 
		if (text == ""):
			var separator: Control = Control.new()
			separator.custom_minimum_size.y = separator_size
			credits_text_container.add_child(separator)
			continue
			
		var text_size: int = int(credits_file.get_line())
		print(text_size)
		# Create the label node set its text
		var label: Label = Label.new()
		label.text = text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		# Set label's font size
		var new_label_settings: LabelSettings = LabelSettings.new()
		new_label_settings.font_size = text_size
		label.label_settings = new_label_settings
		# Add label as a child
		credits_text_container.add_child(label)
		
func _process(delta: float):
	self.position.y += scroll_speed * -1 * delta
