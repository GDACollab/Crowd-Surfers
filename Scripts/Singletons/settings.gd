extends Node

#All settings 0.0-1.0
var master_volume: float = 1.0;
var music_volume: float = 1.0;
var sfx_volume: float = 1.0;

# Get bus paths from FMOD
@onready var master_bus: FmodBus = FmodServer.get_bus("bus:/")
@onready var music_bus: FmodBus = FmodServer.get_bus("bus:/MUS")
@onready var sfx_bus: FmodBus = FmodServer.get_bus("bus:/SFX")

# Other bus paths if we want more options:
# "bus:/SFX/ENV"
# "bus:/SFX/Player"
# "bus:/SFX/UI"

func update_fmod_volumes():
	# update bus volume property
	master_bus.set("volume", master_volume)
	music_bus.set("volume", music_volume)
	sfx_bus.set("volume", sfx_volume)
