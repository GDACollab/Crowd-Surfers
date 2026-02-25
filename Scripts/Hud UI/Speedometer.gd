extends Control

signal speed_changed(new_speed: float)

@onready var bar: TextureProgressBar = $TextureProgressBar
@onready var particle_Gen: CPUParticles2D = $CPUParticles2D

func set_speed(value: float):
	bar.value = value
	
	# experimental code and testing to see if ppl
	# like the particles on speedometer
	if(bar.value >= bar.max_value * .75):
		particle_Gen.visible = true
	else:
		particle_Gen.visible = false


func set_Max_Speed(value:float):
	bar.max_value = value

func set_Particles():
	pass
