extends Node

#All settings 0.0-1.0
var master_volume: float = 1.0;
var music_volume: float = 1.0;
var sfx_volume: float = 1.0;

@onready var master_bus: FmodBus = FmodServer.get_bus("bus:/")
@onready var music_bus: FmodBus = FmodServer.get_bus("bus:/MUS")
@onready var sfx_bus: FmodBus = FmodServer.get_bus("bus:/SFX")

func update_fmod_volumes():
	master_bus.set("volume", master_volume)
	music_bus.set("volume", music_volume)
	sfx_bus.set("volume", sfx_volume)
