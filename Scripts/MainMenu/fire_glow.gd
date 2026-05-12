extends TextureRect

@export var min_alpha: float = 0.2
@export var max_alpha: float = 0.6
@export var flicker_time: float = 0.1
@export var alpha_change_speed: float = 4

var time: float
var target_alpha: float = 0

func _process(delta: float) -> void:
	time += delta
	
	if (time > flicker_time):
		time = 0
		target_alpha = randf_range(min_alpha, max_alpha)
		
	modulate.a = lerp(modulate.a, target_alpha, alpha_change_speed * delta)
