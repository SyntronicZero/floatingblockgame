extends RigidBody3D

#region Nodes
@onready var mesh_rotation_y_node: Node3D = $MeshRotationY
@onready var mesh_rotation_z_node: Node3D = $MeshRotationY/MeshRotationZ
@onready var gravity_rotation_node: Node3D = $GravityRotation
@onready var floor_col_check_node: RayCast3D = $GravityRotation/FloorColCheck

#endregion

@export var camera_node: Node3D
var camera_basis: Basis
var camera_global_basis: Basis

const MESH_ROTATION_SPEED = 15.0
var _theta: float
const ACCELERATION = 5.0
const DECCELERATION = 1.0
const SPEED = 10
const JUMP_VELOCITY = 9
var gravity = 20

var input_dir: Vector2
var direction: Vector3

var set_up_direction: Quaternion
var new_rotation: Quaternion
var gravity_direction: Vector3 = Vector3(0, -1, 0)
var local_velocity: Vector3

func _ready() -> void:
	if camera_node != null:
		camera_basis = camera_node.cam_basis

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("Right Bumper"):
		if camera_node.look_detection_node.is_colliding():
			gravity_direction = -camera_node.look_detection_node.get_collision_normal()

var p_local_velocity_abs: Vector3
var c_local_velocity: Vector3

func _physics_process(_delta: float) -> void:
	prev_smooth_abs = GravityFunctions.get_local_velocity_abs(smooth_move, camera_global_basis) #gets the current local absplute smooth from the smooth_move var

var jumped: bool

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	camera_basis = camera_node.cam_basis
	camera_global_basis = camera_node.cam_global_basis
	set_constant_force(gravity * gravity_direction) #gravity
	if get_gravity(): #gets the gravity from the current area3d node
		gravity_direction = get_gravity().normalized()
	print(get_gravity())
	if is_on_floor(state):
		physics_material_override.friction = 1
	else:
		physics_material_override.friction = 0
		
	c_local_velocity = GravityFunctions.get_local_velocity_direction(p_local_velocity_abs, GravityFunctions.get_local_velocity_abs(linear_velocity, camera_global_basis))
	p_local_velocity_abs = GravityFunctions.get_local_velocity_abs(linear_velocity, camera_global_basis)
	
	if Input.is_action_just_pressed("Jump") and is_on_floor(state):
		apply_impulse(JUMP_VELOCITY * camera_global_basis.y)
		print(c_local_velocity.y)
		jumped = true
	#if Input.is_action_just_released("Jump") and jumped:
		#linear_velocity -= (c_local_velocity.y / 2) * camera_global_basis.y
		#print("canceled")
		#jumped = false
		#pass
	
	
	_get_movement_input()
	if floor_col_check_node.is_colliding():
		#global_position += ((floor_col_check_node.target_position + Vector3(0, 1, 0)) * camera_global_basis.y) 
		position += (_ground_movement(state.step, 1)) * state.step
		_mesh_rotation(state.step, 1)
		linear_damp = 0
		
	else:
		position += (_ground_movement(state.step, .3)) * state.step
		_mesh_rotation(state.step, .5)
		linear_damp = .5
	gravity_rotation(gravity_direction)
	
	pass


var smooth_move: Vector3
var platform_velocity: Vector3
var current_smooth_velocity: Vector3
var prev_smooth_abs: Vector3
var floor_normal

func _ground_movement(delta, friction) -> Vector3:
	var forward = camera_global_basis.z
	var right = camera_global_basis.x
	var movement: Vector3
	movement = forward * input_dir.y * SPEED
	movement += right * input_dir.x * SPEED
	smooth_move = lerp(smooth_move, movement, ACCELERATION * delta * friction)
	return smooth_move

func is_on_floor(state: PhysicsDirectBodyState3D) -> bool:
	for contact in state.get_contact_count():
		var contact_normal = state.get_contact_local_normal(contact)
		if contact_normal.dot(-gravity_direction) > .8:
			return true
	return false

func _mesh_rotation(delta, rotation_strength: float):
	var theta_remaped = remap(abs(_theta), 3, .01, 1, 0.03)
	if direction: #rotates y axis
		_theta = wrapf(atan2(-direction.x, -direction.z) - mesh_rotation_y_node.rotation.y, -PI, PI)
		mesh_rotation_y_node.rotation.y += clamp(theta_remaped * MESH_ROTATION_SPEED * delta * rotation_strength, 0, abs(_theta)) * sign(_theta)
	if abs(_theta) > deg_to_rad(2) and direction: #rotates z axis
		mesh_rotation_z_node.rotation.z = lerp(mesh_rotation_z_node.rotation.z, clamp(theta_remaped * sign(_theta), -deg_to_rad(25), deg_to_rad(25)), .2)
	else:
		mesh_rotation_z_node.rotation.z = lerp(mesh_rotation_z_node.rotation.z, 0.0, .2)

func gravity_rotation(grav_direction) -> void:
	gravity_rotation_node.position = position
	if gravity_direction:
		set_up_direction = Quaternion(gravity_rotation_node.global_basis.y, -grav_direction) * gravity_rotation_node.quaternion
	new_rotation = new_rotation.slerp(set_up_direction, .1)
	gravity_rotation_node.global_basis = set_up_direction
	global_basis = new_rotation

func _get_movement_input() -> void:
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y))
