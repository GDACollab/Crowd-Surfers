extends "res://Scripts/UI/button_highlight.gd"

@export var required_hold_time: float = 1

@onready var delete_sound: FmodEventEmitter2D = $DeleteSound

var hold_time: float = 0
var finished: bool = false

signal button_hold_finished

func _ready() -> void:
	button_hold_finished.connect(delete_sound.play)

func _process(delta: float) -> void:
	if finished: return
	# Update hold_time
	if button_pressed:
		hold_time += delta
	else:
		hold_time -= delta * 2
	
	# Clamp hold_time or emit signal if done
	if hold_time < 0:
		hold_time = 0
	elif hold_time >= required_hold_time:
		button_hold_finished.emit()
		finished = true
		hold_time = 1
	
	_update_fill_bar()

func _update_fill_bar() -> void:
	var mat: ShaderMaterial = material
	var hold_progress := hold_time / required_hold_time
	hold_progress = clampf(hold_progress, 0, 1)
	mat.set_shader_parameter("hold_progress", hold_progress)
