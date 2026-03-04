extends Node

#All settings 0.0-1.0
var master_volume: float = 1.0;
var music_volume: float = 1.0;
var sfx_volume: float = 1.0;

func update_fmod_volumes():
	var music_volume_final: float = master_volume * music_volume
	var sfx_volume_final: float = master_volume * sfx_volume
	
	# fmodsetbusthingy(music_bus, music_volume_final)
	# fmodsetbusthingy(sfx_bus, sfx_volume_final)
