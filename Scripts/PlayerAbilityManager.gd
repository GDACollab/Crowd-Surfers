extends Node

@export var abilities: Array[Ability]

@export var myPlayer: CharacterBody3D

## Time (in seconds) after finishing stomp within which dash can combo
@export var dash_and_stomp_margin: float

var can_glide: bool = true
var activeAbilities: Array[int]
var stomp_speed_boost: float = 0.0

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
			
	# Deactiveate stomp if player is on the ground
	if $StompAbility.is_active and myPlayer.is_on_floor():
		stomp_speed_boost = $StompAbility.player_speed_boost
		print("Stomp speed boost: " + str(stomp_speed_boost))
		$StompAbility.Exit(myPlayer)
		# Start the timer for the margin where dash receives the boost from stomp
		$DashAndStompTimer.start(dash_and_stomp_margin)
		

# This checks user inputs to determine what abilities to call this frame
func checkAbilities() -> Array[int]:
	var indices: Array[int] = []
	# You may have to modify this for the glide
	if Input.is_action_just_pressed("ability_dash"):
		# Pass the stomp speed boost to the dash ability
		$DashAbility.speed_boost_from_stomp = stomp_speed_boost
		indices.append(0)
	# currently for gliding with input 2
	# disables glide when jumping the first time
	if Input.is_action_just_released("ability_glide") and !can_glide:
		can_glide = true
	# do glide if can_glide
	elif (Input.is_action_just_pressed("ability_glide") and can_glide):
		if can_glide && !$GlideAbility.activated:
			
			indices.append(1)
	# re-enable after the button is released
	elif ((Input.is_action_just_released("ability_glide") and can_glide) or (myPlayer.is_on_floor() and can_glide)):
		can_glide = false
		indices.append(1)

	if Input.is_action_just_pressed("ability_stomp"):
		# Player must be midair
		if not myPlayer.is_on_floor():
			indices.append(2)
	return indices


func _on_dash_and_stomp_timer_timeout() -> void:
	# Remove the potential speed boost from stomp once the margin is up
	stomp_speed_boost = 0.0
