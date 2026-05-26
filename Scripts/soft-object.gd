extends Node3D

## Factor to multiply the player's speed by when hitting this object
@export var speed_decrease_factor: float = 0.25
## Time (in seconds) for the object to disappear once touched by the player
@export var time_to_disappear: float = 0.5
## Whether or not this object has already tripped the player
var tripped_player: bool = false

var collide_sound: FmodEventEmitter3D = null

func _on_area_3d_body_entered(player: CharacterBody3D) -> void:
	if tripped_player: 
		return
	# EXECUTIVE DECISION: I don't like how the crash animation looks with soft objects
	# and I think it deserves its own dedicated animation, but we don't have time!
	# - Quincy
	#if player.get_node('AnimatedSprite3D'):
		#player.player_sprite.play_animation("crash")
	player.velocity *= speed_decrease_factor
	tripped_player = true
	set_process(true)
	
	if collide_sound:
		collide_sound.play()
	
func _ready() -> void:
	set_process(false)
	if has_node("CollideSound"):
		collide_sound = get_node("CollideSound")
	
func _process(delta: float) -> void:
	$Sprite3D.modulate.a -= delta / time_to_disappear
	if $Sprite3D.modulate.a <= 0:
		queue_free()
