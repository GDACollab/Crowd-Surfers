extends RichTextLabel

@export_category("Scale Hover Settings")
@export var hovered_scale: float = 1.12
@export var scale_change_seconds: float = 0.15

var is_hovered: bool = false
var last_scale: Vector2 = Vector2.ONE
var last_scale_time: float = 0.0

func _process(_delta: float):
	# t should go from 0 to 1 in scale_change_seconds seconds after last_scale_time :thumbsup:
	var t: float = (float(Time.get_ticks_msec())/1000.0 - last_scale_time) / scale_change_seconds
	t = smoothstep(0.0, 1.0, t)
	
	if (is_hovered and self.scale.x < hovered_scale):
		self.scale = last_scale.lerp(Vector2(hovered_scale, hovered_scale), t)
	elif (not is_hovered and self.scale.x > 1):
		self.scale = last_scale.lerp(Vector2.ONE, t)
	
	self.pivot_offset = self.size * 0.5

func _on_mouse_entered() -> void:
	if (not is_hovered):
		is_hovered = true
		last_scale = self.scale
		last_scale_time = float(Time.get_ticks_msec())/1000.0

func _on_mouse_exited() -> void:
	if (is_hovered):
		is_hovered = false
		last_scale = self.scale
		last_scale_time = float(Time.get_ticks_msec())/1000.0
