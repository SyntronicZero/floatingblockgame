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
var _theta: float
const ACCELERATION = 5.0
const DECCELERATION = 1.0
const SPEED = 10
const JUMP_VELOCITY = 9

var input_dir: Vector2
var direction: Vector3
var global_direction: Vector3

var set_up_direction: Quaternion
var new_rotation: Quaternion
var gravity_direction: Vector3 = Vector3(0, -1, 0)
var local_velocity: Vector3
var set_gravity_speed: float

func _ready() -> void:
	if camera_node != null:
		camera_basis = camera_node.cam_basis

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Right Bumper"):
		if camera_node.look_detection_node.is_colliding():
			gravity_direction = -camera_node.look_detection_node.get_collision_normal()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	camera_basis = camera_node.cam_basis
	camera_global_basis = camera_node.cam_global_basis
	prev_smooth_abs = GravityFunctions.get_local_velocity_abs(smooth_move, camera_global_basis) #gets the current local absplute smooth from the smooth_move var
	if is_on_floor() == false:
		set_gravity_speed += -20 * delta
		print("gravity")
		floor_normal = Vector3(1, 1, 1)
	else:
		set_gravity_speed = 0
		

	#if floor_col_check_node.is_colliding() and not Input.is_action_just_pressed("Jump"):
		#set_gravity_speed = -9.8
		#apply_floor_snap()
		
	#print(set_gravity_speed)

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		set_gravity_speed += JUMP_VELOCITY
	elif Input.is_action_just_released("Jump") and set_gravity_speed > 0:
		set_gravity_speed = set_gravity_speed / 2


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	
	direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y))
	global_direction = (camera_global_basis * Vector3(input_dir.x, 0, input_dir.y))
	if is_on_floor() or floor_col_check_node.is_colliding():
		_ground_movement(delta, 1)
		_mesh_rotation(delta, 1)
	else:
		_ground_movement(delta, .3)
		_mesh_rotation(delta, .5)
	gravity_rotation(gravity_direction)
	move_and_slide()

#func _ground_movement(delta, friction):
	#if input_dir:
		#velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta * friction) #move when input
		#velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta * friction)
	#else:
		#velocity.x = lerp(velocity.x, 0.0, ACCELERATION * delta * friction) #slow to stop when not moving
		#velocity.z = lerp(velocity.z, 0.0, ACCELERATION * delta * friction)
		
		

var smooth_move: Vector3
var platform_velocity: Vector3
var current_smooth_velocity: Vector3
var prev_smooth_abs: Vector3
var floor_normal

func _ground_movement(delta, friction):
	var forward = camera_global_basis.z
	var right = camera_global_basis.x
	var movement: Vector3
	var on_platform: bool = false
	movement = forward * input_dir.y * SPEED
	movement += right * input_dir.x * SPEED
	if get_platform_velocity() and (is_on_floor() or floor_col_check_node.is_colliding()):
		platform_velocity = get_platform_velocity()
	smooth_move = lerp(smooth_move, movement, ACCELERATION * delta * friction)
	print(str(GravityFunctions.get_local_velocity_abs(smooth_move, camera_global_basis)) + " local y")
	current_smooth_velocity = GravityFunctions.get_local_velocity_direction(prev_smooth_abs, GravityFunctions.get_local_velocity_abs(smooth_move, camera_global_basis))
	print(str((smooth_move * camera_global_basis.y).length()) + " smooth y")
	if is_on_floor() or floor_col_check_node.is_colliding():
		platform_velocity = lerp(platform_velocity, get_platform_velocity() * 2, ACCELERATION * delta * friction)
	
	if get_platform_velocity():
		velocity = smooth_move + (set_gravity_speed * camera_global_basis.y) - (clamp(current_smooth_velocity.y, 0, 1) * camera_global_basis.y) #clamp cancels out smooth move y in the positive direction
	else:
		velocity = smooth_move + (set_gravity_speed * camera_global_basis.y) + platform_velocity - (clamp(current_smooth_velocity.y, 0, 1) * camera_global_basis.y)
	
	#print(str(movement) + " movement")
	##print(str(velocity) + " velocity")
	#print(local_velocity)
	
func _mesh_rotation(delta, rotation_strength: float):
	#var mesh_direction = atan2(-direction.x, -direction.z)
	var theta_remaped = remap(abs(_theta), 3, .01, 1, 0.03)
	if direction: #rotates y axis
		_theta = wrapf(atan2(-direction.x, -direction.z) - mesh_rotation_y_node.rotation.y, -PI, PI)
		#mesh_rotation_y_node.rotation.y += clamp(MESH_ROTATION_SPEED * delta, 0, abs(_theta)) * sign(_theta)
		mesh_rotation_y_node.rotation.y += clamp(theta_remaped * MESH_ROTATION_SPEED * delta * rotation_strength, 0, abs(_theta)) * sign(_theta)
	#mesh_rotation_z_node.rotation.z = lerp(mesh_rotation_z_node.rotation.z, clamp(theta_remaped * sign(_theta), -deg_to_rad(25), deg_to_rad(25)) * type_convert(type_convert(direction, TYPE_BOOL), TYPE_INT), .2)
	if abs(_theta) > deg_to_rad(2) and direction and is_on_floor(): #rotates z axis
		mesh_rotation_z_node.rotation.z = lerp(mesh_rotation_z_node.rotation.z, clamp(theta_remaped * sign(_theta), -deg_to_rad(25), deg_to_rad(25)), .2)
	else:
		mesh_rotation_z_node.rotation.z = lerp(mesh_rotation_z_node.rotation.z, 0.0, .2)
		#sprint("rotata")
#clamp(_theta, -deg_to_rad(25), deg_to_rad(25))

#func gravity_rotation(grav_direction) -> void:
	#if gravity_direction:
		#set_up_direction = Quaternion(global_basis.y, -grav_direction) * quaternion
	#new_rotation = new_rotation.slerp(set_up_direction, .2)
	#up_direction = -gravity_direction
	#global_basis = new_rotation
	#
func gravity_rotation(grav_direction) -> void:
	gravity_rotation_node.position = position
	if gravity_direction:
		set_up_direction = Quaternion(gravity_rotation_node.global_basis.y, -grav_direction) * gravity_rotation_node.quaternion
	new_rotation = new_rotation.slerp(set_up_direction, .1)
	up_direction = -gravity_direction
	gravity_rotation_node.global_basis = set_up_direction
	global_basis = new_rotation
