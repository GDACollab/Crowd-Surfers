extends Node
class_name StallBounce

@export var stall : Node3D
@export var stall_area : Area3D
@export var squish_amount : float = 0.8
@export var squish_speed : float = 0.5

func _ready() -> void:
	stall_area.body_entered.connect(_try_squish)
	stall_area.body_exited.connect(_unsquish)

func _try_squish(body : Node3D):
	if body is Player:
		var t = create_tween()
		t.tween_property(stall, "scale", Vector3(1.0, squish_amount, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC)

func _unsquish(body : Node3D):
	if body is Player:
		var t = create_tween()
		t.tween_property(stall, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_ELASTIC)
