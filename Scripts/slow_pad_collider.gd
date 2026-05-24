extends Node3D

@export var slow_multiplier: Vector3 = Vector3(1.1, 1, 1.1)
@export var min_speed: float = 15
var isplayer: bool = false
var player: CharacterBody3D

var collide_sound: FmodEventEmitter3D = null

func _ready() -> void:
	if (has_node("CollideSound")):
		collide_sound = get_node("CollideSound")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (isplayer):
		player.max_speed *= (player.velocity/slow_multiplier).length()/player.velocity.length()
		if (player.max_speed < min_speed): player.max_speed = min_speed
		player.velocity /= slow_multiplier


func _on_area_3d_body_entered(body: Node3D) -> void:
	#print(body.name)
	print('slow enter')
	if (body.name == "Player"):
		isplayer = true
		player = body
		if (collide_sound): collide_sound.play()


func _on_area_3d_body_exited(body: Node3D) -> void:
	#print(body.name)
	print('slow exit')
	if (body.name == "Player"):
		isplayer = false
