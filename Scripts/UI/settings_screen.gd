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

func _process(delta: float) -> void:
	var slide_input: float = Input.get_axis("ui_left", "ui_right")
	
	if not is_equal_approx(slide_input, 0):
		_change_focused_slider(slide_input * delta)

func _change_focused_slider(amount: float) -> void:
	if master_slider.has_focus():
		master_slider.value += amount
	elif music_slider.has_focus():
		music_slider.value += amount
	elif sfx_slider.has_focus():
		sfx_slider.value += amount
	elif voice_slider.has_focus():
		voice_slider.value += amount

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
	Audio.registry["voice_sample"]["pausePosition"] += 200
