extends FmodEventEmitter3D

var current_time: int = 0;
var last_skate_time: int = 0;
var skate_interval: int = 100;
var player: Player;

func _ready() -> void:
	player = get_parent();
	

func _process(delta: float) -> void:
	# Increment time
	current_time += int(delta * 1000);
	
	# Calculate horizontal speed
	var speed: float = Vector2(player.velocity.x, player.velocity.z).length();
	
	# If not on ground or moving slowly, reset time and stop process
	if (player.current_state != player.States.GROUND) or (speed < 5):
		return;
	
	# skate interval is proportional to ratio of speed to max_speed
	# interval is always between 300-1000 ms
	var ratio = clamp(1.0 - (speed / player.base_ramping_cap), 0, 1.0);
	ratio = ratio * ratio;
	skate_interval = 300 + int(ratio * 700);
	
	# Play sound and reset timer
	if current_time > last_skate_time + skate_interval:
		play(true);
		last_skate_time = current_time;
