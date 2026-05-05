class_name CrowdData
var rid_to_mesh_index: int
var group_reference: Array

func _init(rid_ref: int, group: Array):
	rid_to_mesh_index = rid_ref
	group_reference = group
