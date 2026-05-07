extends Node3D

## Factor to multiply the player's speed by when hitting this object
@export var speed_decrease_factor: float = 0.25
## Time (in seconds) for the object to disappear once touched by the player
@export var time_to_disappear: float = 0.5
## Whether or not this object has already tripped the player
var tripped_player: bool = false

func _on_area_3d_body_entered(player: CharacterBody3D) -> void:
	if player is not Player:
		return
	if tripped_player: 
		return
	if player.get_node('AnimatedSprite3D'):
		player.player_sprite.play_animation("crash")
		player.is_playing_crash = true
	player.velocity *= speed_decrease_factor
	tripped_player = true
	set_process(true)
	
func _ready() -> void:
	set_process(false)
	
func _process(delta: float) -> void:
	$Sprite3D.modulate.a -= delta / time_to_disappear
	if $Sprite3D.modulate.a <= 0:
		queue_free()
