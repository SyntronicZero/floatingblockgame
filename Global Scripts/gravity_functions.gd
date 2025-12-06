extends Node


func get_local_velocity_abs(c_velocity: Vector3, c_basis: Basis) -> Vector3:
	var current_velocity: Vector3 = Vector3((c_velocity * c_basis.x).length(), (c_velocity * c_basis.y).length(), (c_velocity * c_basis.z).length())
	return current_velocity

func get_local_velocity_direction(p_local, c_local) -> Vector3:
	var current_velocity: Vector3
	current_velocity.x = c_local.x * sign(c_local.x - p_local.x)
	current_velocity.y = c_local.y * -sign(c_local.y - p_local.y)
	current_velocity.z = c_local.z * sign(c_local.z - p_local.z)
	return current_velocity
