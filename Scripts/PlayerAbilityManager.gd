extends Node

@export var abilities: Array[Ability]

@export var myPlayer: CharacterBody3D

var activeAbilities: Array[int]

func _process(_delta: float) -> void:
	var inputs = checkAbilities()
	for i in inputs:
		# Check to see if the parent of this is the player script, to prevent crashes
		if myPlayer != null:
			# This node needs a player_controller as a parent!
			# Nothing happens if it's not
			abilities[i].Use(get_parent())
			activeAbilities.append(i)
		else:
			print("You still need to set the player in the ability manager!")
			
	# Prepare list of abilities to deactivate
	var abilitiesToDeactivate: Array[int]
	# Check each active ability
	for i in activeAbilities:
		# Deactivate stomp is player is on the floor
		if abilities[i] == $StompAbility and myPlayer.is_on_floor():
			$StompAbility.Exit(myPlayer)
			abilitiesToDeactivate.append(i)
			
	# Amend list of active abilities
	for i in abilitiesToDeactivate:
		activeAbilities.erase(i)
	
	

# This checks user inputs to determine what abilities to call this frame
func checkAbilities() -> Array[int]:
	var indices: Array[int] = []
	# You may have to modify this for the glide
	if Input.is_action_just_pressed("ability_dash"):
		indices.append(0)
	if Input.is_action_just_pressed("ability_2"):
		indices.append(1)
	if Input.is_action_just_pressed("ability_stomp"):
		# Player must be midair
		if not myPlayer.is_on_floor():
			indices.append(2)
	return indices
