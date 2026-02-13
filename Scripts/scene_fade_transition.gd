extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var transitioning: bool = false

func _ready():
	self.visible = false

func transition_to_scene(finalScene: PackedScene):
	if (transitioning):
		return
	
	transitioning = true
	self.visible = true
	animation_player.play("fade_in")
	
	# Wait 1s for animation
	await get_tree().create_timer(1.0).timeout 

	# Change scenes to finalScene, wait while this happens
	print("Changing to: ", finalScene.resource_path)

	get_tree().change_scene_to_packed(finalScene)
	await get_tree().process_frame

	animation_player.play("fade_out")
	
	# Wait 1s for animation
	await get_tree().create_timer(1.0).timeout 
	
	self.visible = false
	transitioning = false
