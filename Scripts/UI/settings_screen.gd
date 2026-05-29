extends Control

@onready var master_slider: HSlider = $SettingsBody/MasterSliderHolder/MasterSlider
@onready var music_slider: HSlider = $SettingsBody/MusicSliderHolder/MusicSlider
@onready var sfx_slider: HSlider = $SettingsBody/SFXSliderHolder/SFXSlider
@onready var voice_slider: HSlider = $SettingsBody/VoiceSliderHolder/VoiceSlider
@onready var voice_slider_sample : FmodEvent

func _ready() -> void:
	master_slider.set_value_no_signal(Settings.master_volume)
	music_slider.set_value_no_signal(Settings.music_volume)
	sfx_slider.set_value_no_signal(Settings.sfx_volume)
	voice_slider.set_value_no_signal(Settings.voice_volume)
	Settings.update_fmod_volumes()

func _on_master_slider_value_changed(value: float) -> void:
	Settings.master_volume = value
	Settings.update_fmod_volumes()

func _on_music_slider_value_changed(value: float) -> void:
	Settings.music_volume = value
	Settings.update_fmod_volumes()

func _on_sfx_slider_value_changed(value: float) -> void:
	Settings.sfx_volume = value
	Settings.update_fmod_volumes()
	
func _on_voice_slider_value_changed(value: float) -> void:
	Settings.voice_volume = value
	Settings.update_fmod_volumes()

func _on_voice_slider_drag_started() -> void:
	if (voice_slider_sample == null):
		voice_slider_sample = Audio.create_persistent("voice_sample", "event:/SFX/UI/settings_voicevolume_sample", true)
		voice_slider_sample.start()	
	else:
		Audio.unpause_persistent("voice_sample")

func _on_voice_slider_drag_ended(_value_changed: bool) -> void:
	Audio.pause_persistent("voice_sample")
