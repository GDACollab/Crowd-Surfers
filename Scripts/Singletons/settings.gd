extends Node

#All settings 0.0-1.0
var master_volume: float = 1.0;
var music_volume: float = 1.0;
var sfx_volume: float = 1.0;
	
func update_fmod_volumes():
	#For some reason the busses cant be @onready, it didnt work when switching between (or reloading) scenes
	# Other bus paths if we want more options:
	# "bus:/SFX/ENV"
	# "bus:/SFX/Player"
	# "bus:/SFX/UI"
	var master_bus: FmodBus = FmodServer.get_bus("bus:/")
	var music_bus: FmodBus = FmodServer.get_bus("bus:/MUS")
	var sfx_bus: FmodBus = FmodServer.get_bus("bus:/SFX")

	# update bus volume property
	master_bus.set("volume", master_volume)
	music_bus.set("volume", music_volume)
	sfx_bus.set("volume", sfx_volume)
	
	
