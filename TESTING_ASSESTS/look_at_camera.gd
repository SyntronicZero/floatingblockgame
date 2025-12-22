extends MeshInstance3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_viewport().get_camera_3d():
		look_at(get_viewport().get_camera_3d().global_position, Vector3.UP, true)
	pass
