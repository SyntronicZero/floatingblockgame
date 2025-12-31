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

func alt_local_velocity(vel, basis) -> Vector3: #better local velocity
	var local_vel: Vector3
	var vel_norm = vel.normalized()
	var vel_len = vel.length()
	local_vel.y = basis.y.dot(vel_norm) * vel_len
	local_vel.x = basis.x.dot(vel_norm) * vel_len
	local_vel.z = basis.z.dot(vel_norm) * vel_len
	
	return local_vel

func get_gravity_direction(gravity_zones: Array, phys_node: PhysicsBody3D) -> Vector3: #custom solution for handeling gravity zones
	var grav_dir: Vector3 = Vector3.ZERO
	var priority_list: Array
	var gravity_directions: Array
	var grav_index: int = 0
	var grav_zones_flipped: Array
	grav_zones_flipped.assign(gravity_zones)
	grav_zones_flipped.reverse()
	if gravity_zones.is_empty() == false:
		for node in grav_zones_flipped: #gets the the priorities of each zone
			priority_list.append(node.get_priority())
		for node in grav_zones_flipped:
			if node.get_priority() == priority_list.max(): #checks the priority of the node against the highest one available
				if node.is_gravity_a_point() and node.gravity_path == null:
					var parent_scale: Vector3
					var rotation_node: Node3D
					if node.get_parent_node_3d():
						parent_scale = (node.get_parent_node_3d()).scale
						rotation_node = node.get_parent_node_3d()
					else:
						parent_scale = Vector3.ONE
					gravity_directions.append(((node.global_position + _rotate_vector3_in_yxz_euler(node.get_gravity_point_center() * parent_scale, rotation_node.rotation)) - phys_node.global_position).normalized() * sign(node.gravity))
				elif node.is_gravity_a_point() and node.gravity_path != null:
					gravity_directions.append(_get_gravity_point_from_path(node.gravity_path, phys_node) * sign(node.gravity))
				else: #grav direction. Points towards a direction local to the GravityZone
					gravity_directions.append(_rotate_vector3_in_yxz_euler(node.get_gravity_direction(), node.rotation).normalized()  * sign(node.gravity))
				if node.get_gravity_space_override_mode() == 3:
					return gravity_directions[grav_index]
				grav_index += 1
		for grav in gravity_directions:
			grav_dir += grav
		return grav_dir.normalized()
	return Vector3.ZERO

func _get_gravity_point_from_path(path: Path3D, node: Node3D) -> Vector3:
	var curve_point: Vector3
	var relative_pos = _get_local_position(path, node)
	var offset_pos: float = path.curve.get_closest_offset(relative_pos)
	curve_point = path.curve.sample_baked(offset_pos) + (path.global_position - node.global_position) 
	return curve_point.normalized()

func _get_local_position(local_node: Node3D, relative_node: Node3D) -> Vector3:
	var local_position: Vector3
	local_position = relative_node.global_position - local_node.global_position
	return local_position

func transform_curve_points(new_path: Path3D, ref_path: Path3D) -> void: ##Modifies the new path based on the reference paths curve points, scale, and global rotation.
	var c_curve: Curve3D = new_path.curve
	var c_point: int = 0
	while c_point < ref_path.curve.get_point_count():
		if c_curve.get_point_count() != ref_path.curve.get_point_count():
			c_curve.add_point(_rotate_vector3_in_yxz_euler(ref_path.curve.get_point_position(c_point) * ref_path.scale, ref_path.rotation), 
							  _rotate_vector3_in_yxz_euler(ref_path.curve.get_point_in(c_point) * ref_path.scale, ref_path.rotation), 
							  _rotate_vector3_in_yxz_euler(ref_path.curve.get_point_out(c_point) * ref_path.scale, ref_path.rotation), 
							  c_point)
		else:
			c_curve.set_point_position(c_point, _rotate_vector3_in_yxz_euler(ref_path.curve.get_point_position(c_point) * ref_path.scale, ref_path.rotation))
			c_curve.set_point_in(c_point, _rotate_vector3_in_yxz_euler(ref_path.curve.get_point_in(c_point) * ref_path.scale, ref_path.rotation))
			c_curve.set_point_out(c_point, _rotate_vector3_in_yxz_euler(ref_path.curve.get_point_out(c_point) * ref_path.scale, ref_path.rotation))
		#print(c_curve.get_point_position(c_point))
		c_point += 1


func _rotate_vector3_in_yxz_euler(input_vector: Vector3, rotation_vector: Vector3) -> Vector3: ##Rotates a vector3 based on a given rotation vector in Radians. Assumes Vector3.ZERO is the origin.
	var rotated_vector: Vector3
	rotated_vector = input_vector.rotated(Vector3.UP, rotation_vector.y)
	rotated_vector = rotated_vector.rotated(Vector3.RIGHT.rotated(Vector3.UP, rotation_vector.y), rotation_vector.x)
	rotated_vector = rotated_vector.rotated(Vector3.BACK.rotated(Vector3.RIGHT, rotation_vector.x).rotated(Vector3.UP, rotation_vector.y), rotation_vector.z)
	return rotated_vector
