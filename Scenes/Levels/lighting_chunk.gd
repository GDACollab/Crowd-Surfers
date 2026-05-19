extends Area3D
class_name LightingChunk

## Lights to be active when in this chunk
@export var lights : Array[Light3D]

func _ready() -> void:
	var initial_bodies = get_overlapping_bodies()
	for b in initial_bodies:
		if b is Player:
			print("Found starting chunk")
			return
	print("Chunk disabled")
	for l in lights:
		l.visible = false
		l.process_mode = Node.PROCESS_MODE_DISABLED

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		for l in lights:
			l.process_mode = Node.PROCESS_MODE_INHERIT
			l.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		for l in lights:
			l.visible = false
			l.process_mode = Node.PROCESS_MODE_DISABLED
