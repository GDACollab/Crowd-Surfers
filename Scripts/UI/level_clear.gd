extends Control

@export var hud_ui: Control
@export var level_number: int
@export var button_scale_amount: float = 1.1

@onready var level_clear_holder: Control = $Background/LevelClearHolder
@onready var clear_time_holder: Control = $Background/ClearTimeHolder
@onready var best_time_holder: Control = $Background/BestTimeHolder
@onready var stars: Control = $Background/BackgroundElements/Stars

@onready var clear_time_sprite: TextureRect = $Background/ClearTimeHolder/ClearTime
@onready var clear_time_text: Label = $Background/ClearTimeHolder/ClearTime/ClearTimeText

@onready var best_time_sprite: TextureRect = $Background/BestTimeHolder/BestTime
@onready var best_time_text: Label = $Background/BestTimeHolder/BestTime/BestTimeText

@onready var level_clear_sprite: TextureRect = $Background/LevelClearHolder/LevelClear
@onready var restart_button: TextureButton = $Background/RestartButton
@onready var continue_button: TextureButton = $Background/ContinueButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var level_clear_music : FmodEvent
var has_control_focus: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	level_clear_sprite.scale = Vector2.ZERO
	clear_time_sprite.scale = Vector2.ZERO
	best_time_sprite.scale = Vector2.ZERO
	
	# dont grab focus until this ui is opened
	focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED

func _process(delta: float) -> void:
	level_clear_holder.scale = level_clear_holder.scale.lerp(Vector2.ONE, delta)
	clear_time_holder.scale = clear_time_holder.scale.lerp(Vector2.ONE, delta)
	best_time_holder.scale = best_time_holder.scale.lerp(Vector2.ONE, delta)
	restart_button.scale = restart_button.scale.lerp(Vector2.ONE * 1.5, delta)
	continue_button.scale = continue_button.scale.lerp(Vector2.ONE * 1.5, delta)
	
	# Disable mouse input while animating
	if animation_player.is_playing():
		restart_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		continue_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		continue_button.mouse_filter = Control.MOUSE_FILTER_STOP

func _unhandled_input(event: InputEvent) -> void:
	# grab focus if a ui direction is used
	if (not has_control_focus and not animation_player.is_playing() and
			(event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or 
			 event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"))):
		has_control_focus = true
		$Background/ContinueButton.grab_focus()
		
func open_ui() -> void:
	# Disable pause holder to stop interfering with this ui
	$"../PauseHolder".focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	has_control_focus = false
	
	#don't adjust save file if not assigned
	if level_number > 0:
		SaveDataManager.levels_complete[level_number-1] = true
		#level times being 0.0 means the level has no set time
		if hud_ui.curr_Time < SaveDataManager.level_times[level_number-1] or SaveDataManager.level_times[level_number-1] == 0.0:
			SaveDataManager.level_times[level_number-1] = hud_ui.curr_Time
		SaveDataManager.save_data()
		
	clear_time_text.text = hud_ui.get_Formatted_Timer_Text(hud_ui.curr_Time, false) + hud_ui.get_Formatted_Timer_Text(hud_ui.curr_Time, true)
	if level_number > 0:
		best_time_text.text = hud_ui.get_Formatted_Timer_Text(SaveDataManager.level_times[level_number-1], false) + hud_ui.get_Formatted_Timer_Text(SaveDataManager.level_times[level_number-1], true)
		
	animation_player.play("show_level_clear")
	
	Audio.kill_all_persistents()
	level_clear_music = Audio.create_persistent("mus_clear", "event:/MUS/clear")
	level_clear_music.set_callback(Callable(self, "_handle_beat_events"), FmodServer.FMOD_STUDIO_EVENT_CALLBACK_ALL)
	if ($NowPlaying != null): $NowPlaying.play_banner_animation()
	level_clear_music.start()
	
 ## FMOD event callback trigger, occurs every beat based on the event's desginated tempo
func _handle_beat_events(_dict: Dictionary, type: int) -> void: 
	if type == FmodServer.FMOD_STUDIO_EVENT_CALLBACK_TIMELINE_BEAT:
		_animate_to_beat()
		Audio.ui_pulsing = true

func _animate_to_beat() -> void:
	level_clear_holder.scale = Vector2.ONE * button_scale_amount
	clear_time_holder.scale = Vector2.ONE * button_scale_amount
	best_time_holder.scale = Vector2.ONE * button_scale_amount
	restart_button.scale = Vector2.ONE * 1.5 * button_scale_amount
	continue_button.scale = Vector2.ONE * 1.5 * button_scale_amount
	
	level_clear_sprite.rotation *= -1
	for star: TextureRect in stars.get_children():
		star.rotation *= -1
	
func _on_restart_button_pressed() -> void:
	FmodServer.play_one_shot("event:/SFX/UI/menu_back")
	SceneFadeTransition.transition_to_scene(load(get_tree().current_scene.scene_file_path))
	get_tree().paused = false
	queue_free()

func _exit_tree() -> void:
	Audio.ui_pulsing = false
	Audio.kill_persistent("mus_clear")
	
func _on_continue_button_pressed() -> void:
	FmodServer.play_one_shot("event:/SFX/UI/menu_confirm")
	Story.post_level = true
	Story.next_scene = "res://Scenes/UI Menus/MainMenu/MainMenu.tscn"
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/level_dialogue_player.tscn"))
	await get_tree().create_timer(SceneFadeTransition.FADE_TIME - 0.1).timeout 
	get_tree().paused = false

func scale_level_clear():	
	var tween: Tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(level_clear_sprite, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_BACK)
	
func scale_clear_time():	
	var tween: Tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(clear_time_sprite, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_BACK)
	
func scale_best_time():	
	var tween: Tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(best_time_sprite, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_BACK)
	
