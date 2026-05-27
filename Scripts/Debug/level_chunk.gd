extends Area3D
class_name LevelChunk

@export var has_player := false
var layer_dictionary : Dictionary[Node3D, int]
var areas : Array[Area3D]

func _ready():
	var original_mask = collision_mask
	collision_mask = 1
	call_deferred("get_bodies", original_mask)

func get_bodies(original_mask : int):
	for c in get_overlapping_bodies():
		if c is StaticBody3D:
			layer_dictionary[c] = c.collision_layer
	for a in get_overlapping_areas():
		if a is Area3D:
			areas.append(a)
	collision_mask = original_mask
	var _result = _cull() if !has_player else _uncull()

func _cull():
	print("Culling")
	for b in layer_dictionary.keys():
		b.collision_layer = 0
		b.visible = false
	for a in areas:
		a.monitoring = false

func _uncull():
	print("Unculling")
	for b in layer_dictionary.keys():
		b.collision_layer = layer_dictionary[b]
		b.visible = true
	for a in areas:
		a.monitoring = true
