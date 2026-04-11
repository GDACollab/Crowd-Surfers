extends Node3D

@export var slow_multiplier: Vector3 = Vector3(1.25, 1, 1.25)
var isplayer: bool = false
var player: CharacterBody3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (isplayer):
		player.velocity /= slow_multiplier


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body.name)
	print('slow enter')
	if (body.name == "Player"):
		isplayer = true
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	print(body.name)
	print('slow exit')
	if (body.name == "Player"):
		isplayer = false
