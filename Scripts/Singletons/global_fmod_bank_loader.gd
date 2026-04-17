extends FmodBankLoader


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FmodServer.load_bank("bank:/Master", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	FmodServer.load_bank("bank:/UI", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	FmodServer.load_bank("bank:/CHAR", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	FmodServer.load_bank("bank:/Level", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)

# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass
