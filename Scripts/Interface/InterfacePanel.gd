extends Control
class_name InterfacePanel

@export var transitionSpeed : float = 1.0
@export var showPosition : Vector2
@export var hidePosition : Vector2

func _ready() -> void:
	global_position = hidePosition

func showPanel():
	var t = create_tween()
	t.tween_property(self,"global_position",showPosition, transitionSpeed).set_trans(Tween.TRANS_ELASTIC)

func hidePanel():
	var t = create_tween()
	t.tween_property(self,"global_position",hidePosition, transitionSpeed).set_trans(Tween.TRANS_ELASTIC)
