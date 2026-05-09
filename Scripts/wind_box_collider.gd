extends Node3D

@export var boostDirection: Vector3 = Vector3(0, 1, 0)
@export var boostPower: float = 50.0
@export var speedCap: float = 250.0
var isplayer: bool = false
var player: CharacterBody3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (isplayer):
		if boostDirection.y != 0:
			player.touched_windbox = true
		if (player.velocity.length() < speedCap):
			print("fire")
			player.velocity += boostDirection.normalized() * boostPower
			player.player_sprite.play_animation("jump")

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
