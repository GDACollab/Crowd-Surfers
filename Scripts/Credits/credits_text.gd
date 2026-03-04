extends RichTextLabel

@export_category("Scale Hover Settings")
@export var hovered_scale: float = 1.12
@export var scale_change_seconds: float = 0.15

@export_category("Color Hover Settings")
@export var hovered_brightness: float = 1.0
@export var normal_brightness: float = 0.8

var is_hovered: bool = false
var last_scale: Vector2 = Vector2.ONE
var last_color_brightness: float = 1.0
var last_hover_change_time: float = 0.0

func _ready():
	self.modulate = Color(normal_brightness, normal_brightness, normal_brightness)
	
func _process(_delta: float):
	check_is_hovered()
	
	# t should go from 0 to 1 in scale_change_seconds seconds after last_scale_time :thumbsup:
	var t: float = (float(Time.get_ticks_msec())/1000.0 - last_hover_change_time) / scale_change_seconds
	t = smoothstep(0.0, 1.0, t)
	
	# Gradually change scale and color
	if (is_hovered and self.scale.x < hovered_scale):
		self.scale = last_scale.lerp(Vector2(hovered_scale, hovered_scale), t)
		var brightness: float = lerp(last_color_brightness, hovered_brightness, t)
		self.modulate = Color(brightness, brightness, brightness)
	elif (not is_hovered and self.scale.x > 1):
		self.scale = last_scale.lerp(Vector2.ONE, t)
		var brightness: float = lerp(last_color_brightness, normal_brightness, t)
		self.modulate = Color(brightness, brightness, brightness)
		
	self.pivot_offset = self.size * 0.5

func check_is_hovered() -> void:
	var is_hovered_new: bool = get_global_rect().has_point(get_global_mouse_position())
	
	if (is_hovered_new != is_hovered):
		last_scale = self.scale
		last_color_brightness = self.modulate.r
		last_hover_change_time = float(Time.get_ticks_msec())/1000.0
		is_hovered = is_hovered_new
		
