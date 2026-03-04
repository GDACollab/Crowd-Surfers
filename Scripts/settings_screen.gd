extends Control

@onready var master_slider: HSlider = $ScrollMask/ScrollContainer/VBoxContainer/MasterSliderHolder/MasterSlider
@onready var music_slider: HSlider = $ScrollMask/ScrollContainer/VBoxContainer/MusicSliderHolder/MusicSlider
@onready var sfx_slider: HSlider = $ScrollMask/ScrollContainer/VBoxContainer/SFXSliderHolder/SFXSlider

func _ready() -> void:
	master_slider.set_value_no_signal(Settings.master_volume)
	music_slider.set_value_no_signal(Settings.music_volume)
	sfx_slider.set_value_no_signal(Settings.sfx_volume)

func _on_master_slider_value_changed(value: float) -> void:
	Settings.master_volume = value
	Settings.update_fmod_volumes()

func _on_music_slider_value_changed(value: float) -> void:
	Settings.music_volume = value
	Settings.update_fmod_volumes()

func _on_sfx_slider_value_changed(value: float) -> void:
	Settings.sfx_volume = value
	Settings.update_fmod_volumes()
