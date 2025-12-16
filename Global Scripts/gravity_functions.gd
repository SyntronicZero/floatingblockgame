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

func get_gravity_direction(gravity_zones: Array, phys_node: PhysicsBody3D) -> Vector3:
	var grav_dir: Vector3
	var priority_list: Array
	var gravity_directions: Array
	if gravity_zones.is_empty() == false:
		for node in gravity_zones: #gets the the priorities of each zone
			priority_list.append(node.get_priority())
		for node in gravity_zones:
			if node.get_priority() == priority_list.max(): #checks the priority of the node against the highest one available
				if node.is_gravity_a_point():
					var parent_scale: Vector3
					if node.get_parent_node_3d():
						parent_scale = (node.get_parent_node_3d()).scale
					else:
						parent_scale = Vector3.ONE
					gravity_directions.append(((node.global_position + (node.get_gravity_point_center() * parent_scale)) - phys_node.global_position).normalized())
				else:
					gravity_directions.append((node.get_gravity_direction()).normalized())
				if node.get_gravity_space_override_mode() == 3:
					print("override")
					return phys_node.get_gravity().normalized()
		for grav in gravity_directions:
			grav_dir += grav
		return grav_dir.normalized()
	
	return Vector3(0, -1, 0)
