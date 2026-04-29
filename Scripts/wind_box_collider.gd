extends Node3D

@export var direction: Vector3 = Vector3(0, 1, 0)
@export var speed: float = 50.0
@export var speedCap: float = 250.0
var isplayer: bool = false
var player: CharacterBody3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (isplayer):
		if direction.y != 0:
			player.transition_to(player.States.AIR)
		if (player.velocity.dot(direction.normalized()) < speedCap):
			player.velocity += direction.normalized() * speed

func _on_area_3d_body_entered(body: Node3D) -> void:
	#print(body.name)
	print('wind enter')
	if (body.name == "Player"):
		isplayer = true
		player = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	print(body.name)
	print('wind exit')
	if (body.name == "Player"):
		isplayer = false
