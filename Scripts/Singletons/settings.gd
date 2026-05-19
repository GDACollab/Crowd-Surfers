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
	
	# Marlowe: changed to VCAs so bus mixing faders are not overwritten and so reverb volume changes with SFX volume
	var master_vca: FmodVCA = FmodServer.get_vca("vca:/MASTER")
	var music_vca: FmodVCA = FmodServer.get_vca("vca:/MUS")
	var sfx_vca: FmodVCA = FmodServer.get_vca("vca:/SFX")

	if (master_vca.is_valid()):
		print("Master volume: " + str(master_vca.get("volume")))
		master_vca.set("volume", master_volume)
		music_vca.set("volume", music_volume)
		sfx_vca.set("volume", sfx_volume)
		
	else:
		return
	
	
