extends Node

@export var abilities: Array[Ability]

@export var myPlayer: CharacterBody3D

func _process(_delta: float) -> void:
	
	var inputs = checkAbilities()
	for i in inputs:
		# Check to see if the parent of this is the player script, to prevent crashes
		if myPlayer != null:
			# This node needs a player_controller as a parent!
			# Nothing happens if it's not
			abilities[i].Use(get_parent())
		else:
			print("You still need to set the player in the ability manager!")

# This checks user inputs to determine what abilities to call this frame
func checkAbilities() -> Array[int]:
	var indices: Array[int] = []
	# You may have to modify this for the glide
	if Input.is_action_just_pressed("ability_1"):
		indices.append(0)
	if Input.is_action_just_pressed("ability_2"):
		indices.append(1)
	# currently for gliding with input 3
	if Input.is_action_just_pressed("ability_3") or Input.is_action_just_released("ability_3"):
		indices.append(2)

	return indices
