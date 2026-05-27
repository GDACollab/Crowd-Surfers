extends Node

@export var rotate_speed: float = 15.0
@export var rotate_strength: float = 0.4

var timer: float = 0.0
var random_time_offset: float

func _ready():
	if (randf_range(0.0, 1.0) < 0.5):
		rotate_strength *= -1
	random_time_offset = randf_range(0.0, PI)
		
func _process(delta: float) -> void:
	timer += delta
	self.rotation.z = sin((timer + random_time_offset) * rotate_speed) * rotate_strength
