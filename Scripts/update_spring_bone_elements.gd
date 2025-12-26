@tool
extends EditorScript
var Drag: float = .2
var Stiffness: float = 1


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	for node in get_all_children(get_scene()):
		if node is SpringBoneSimulator3D:
			for element_id in node.get_index():
				node.set_drag(element_id, Drag)
				node.set_stiffness(element_id, Stiffness)
	
	
	pass

func get_all_children(in_node, children_acc = []):
	children_acc.push_back(in_node)
	for child in in_node.get_children():
		children_acc = get_all_children(child, children_acc)

	return children_acc
