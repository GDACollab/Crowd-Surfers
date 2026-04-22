extends Node3D

@export var do_transparency: bool = false

@onready var transparency := Transparency.new($StaticBody3D/TopSprite, $StaticBody3D/FrontSprite)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	transparency.set_do_transparency(do_transparency, global_position.z)
