extends Node3D

@onready var blockade : Node3D = $"../Blockade"
@onready var fence : Node3D = $"../FenceTemp"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Entered checkpoint ", body.name)
	if (body.name == "Player"):
		blockade.position.x = 500.0
		blockade.position.y = -1000.0
		blockade.position.z = 100.0
		fence.position.x = 925.0
		fence.position.y = 35.0
		fence.position.z = 125.0
