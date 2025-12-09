extends CharacterBody3D

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
const ACCELERATION: float = 5.0
const DECCELERATION: float = 20.0
const SPEED: float = 10.0
const JUMP_VELOCITY: float = 9.0
var gravity_speed: float = -20.0

var input_dir: Vector2
var direction: Vector3
var _theta: float

var smooth_target_up_direction: Quaternion
var gravity_direction: Vector3 = Vector3(0, -1, 0)

func _ready() -> void:
	if camera_node != null: #checks for camera node
		camera_basis = camera_node.cam_basis
		camera_global_basis = camera_node.cam_global_basis

func _input(_event: InputEvent) -> void: 
	if Input.is_action_pressed("Right Bumper"): #temp way to test gravity change
		if camera_node.look_detection_node.is_colliding():
			gravity_direction = -camera_node.look_detection_node.get_collision_normal()

var c_local_velocity_abs: Vector3
var c_local_velocity: Vector3

func _physics_process(delta: float) -> void:
	if camera_node != null: #checks for camera node
		camera_basis = camera_node.cam_basis #gets the camera basis relative to its parent node
		camera_global_basis = camera_node.cam_global_basis #gets the cameras basis relative to world space
	
	c_local_velocity = GravityFunctions.get_local_velocity_direction(c_local_velocity_abs, GravityFunctions.get_local_velocity_abs(velocity, camera_global_basis))
	c_local_velocity_abs = GravityFunctions.get_local_velocity_abs(velocity, camera_global_basis)
	
	if is_on_floor() == false:
		print("gravity")
		velocity += (gravity_speed * camera_global_basis.y * delta) #gravity
		velocity = velocity.move_toward(Vector3.ZERO, delta * DECCELERATION / 5)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, delta * DECCELERATION)

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity += JUMP_VELOCITY * camera_global_basis.y
		
	_get_movement_input()
	_add_platform_velocity()
	if is_on_floor() or floor_col_check_node.is_colliding():
		_ground_movement(delta, 1)
		_mesh_rotation(delta, 1)
	else:
		_ground_movement(delta, .3)
		_mesh_rotation(delta, .5)
	gravity_rotation(gravity_direction)
	move_and_slide()


var smooth_move: Vector3
var platform_velocity: Vector3

func _ground_movement(delta, friction):
	var forward = camera_global_basis.z
	var right = camera_global_basis.x
	var movement: Vector3 #movement direction based on input and direction
	movement = forward * input_dir.y * SPEED
	movement += right * input_dir.x * SPEED
	smooth_move = lerp(smooth_move, movement, ACCELERATION * delta * friction) #smooths movement input
	position += smooth_move * delta #modifies position for user input movement instead of velocity
	
func _mesh_rotation(delta, rotation_strength: float):
	var theta_remaped = remap(abs(_theta), 3, .01, 1, 0.03)
	if direction: #rotates y axis
		_theta = wrapf(atan2(-direction.x, -direction.z) - mesh_rotation_y_node.rotation.y, -PI, PI)
		mesh_rotation_y_node.rotation.y += clamp(theta_remaped * MESH_ROTATION_SPEED * delta * rotation_strength, 0, abs(_theta)) * sign(_theta)
	if abs(_theta) > deg_to_rad(2) and direction and is_on_floor(): #rotates z axis
		mesh_rotation_z_node.rotation.z = lerp(mesh_rotation_z_node.rotation.z, clamp(theta_remaped * sign(_theta), -deg_to_rad(25), deg_to_rad(25)), .2)
	else:
		mesh_rotation_z_node.rotation.z = lerp(mesh_rotation_z_node.rotation.z, 0.0, .2)

func gravity_rotation(grav_direction) -> void:
	gravity_rotation_node.position = position
	
	var target_up_direction = Quaternion(gravity_rotation_node.global_basis.y, -grav_direction) * gravity_rotation_node.quaternion
	smooth_target_up_direction = smooth_target_up_direction.slerp(target_up_direction, .1)
	up_direction = -gravity_direction #sets characterbody3D up direction to the inverse of the gravity direction
	gravity_rotation_node.global_basis = target_up_direction
	global_basis = smooth_target_up_direction

func _add_platform_velocity() -> void:
	if get_platform_velocity() and (is_on_floor() or floor_col_check_node.is_colliding()):
		platform_velocity = lerp(platform_velocity, get_platform_velocity(), .2)
	else:
		velocity += platform_velocity * 1.25
		platform_velocity = Vector3.ZERO

func _get_movement_input() -> void:
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y))
