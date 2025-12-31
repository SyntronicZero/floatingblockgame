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

const MAX_VELOCITY: float = 25
const MESH_ROTATION_SPEED = 15.0
const ACCELERATION: float = 5.0
const DECCELERATION: float = 20.0
const SPEED: float = 8.5
const JUMP_VELOCITY: float = 9.0
const JUMP_TOTAL: int = 2
var gravity_speed: float = -20.0

const COYOTE_TIME: float = .15
var air_time: float

var input_dir: Vector2
var direction: Vector3
var _theta: float
var can_jump: int
var state: String = "grounded"

var smooth_target_up_direction: Quaternion
var gravity_direction: Vector3 = Vector3(0, -1, 0)
var gravity_zones: Array


func _ready() -> void:
	if camera_node != null: #checks for camera node
		camera_basis = camera_node.cam_basis
		camera_global_basis = camera_node.cam_global_basis
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(_event: InputEvent) -> void: 
	if Input.is_action_pressed("Right Bumper"): #temp way to test gravity change
		if camera_node.look_detection_node.is_colliding():
			gravity_direction = -camera_node.look_detection_node.get_collision_normal()

var c_local_velocity_abs: Vector3
var c_local_velocity: Vector3
var can_apply_floor_snap: bool
var time_going_up: float
var floor_norm_grav: bool

func _physics_process(delta: float) -> void:
	#wall_cancel = smooth_move.dot(get_wall_normal()) * get_wall_normal()
	#print(wall_cancel)
	#wall_cancel = Vector3.ONE - (abs((abs(smooth_move.normalized().dot(get_wall_normal()))) * get_wall_normal()))
	velocity -= smooth_move #subtracts smooth_move from last frame
	if is_on_floor() and floor_norm_grav:
		gravity_direction = -self.get_floor_normal()
	#gravity_direction = (gravity_point.global_position - position).normalized()
	if Input.is_action_just_pressed("Left Bumper"):
		if floor_norm_grav == false:
			floor_norm_grav = true
		else:
			floor_norm_grav = false
	
	if air_time > COYOTE_TIME and can_jump == JUMP_TOTAL:
		can_jump -= 1
	
	if GravityFunctions.get_gravity_direction(gravity_zones, self): #gets the gravity from the current area3d node
		gravity_direction = GravityFunctions.get_gravity_direction(gravity_zones, self)
	
	if camera_node != null: #checks for camera node
		camera_basis = camera_node.cam_basis #gets the camera basis relative to its parent node
		camera_global_basis = camera_node.cam_global_basis #gets the cameras basis relative to world space
	
	c_local_velocity = GravityFunctions.alt_local_velocity(get_real_velocity(), camera_global_basis)
	#var real_vel_y_canceled = get_real_velocity() - (camera_global_basis.y * c_local_velocity.y)
	#print("%s: Input, %s: Real Vel" % [smooth_move, real_vel_y_canceled])
	#print(smooth_move.dot(real_vel_y_canceled) / (SPEED ** 2))
	#var dir_strength: float = (movement.normalized() * SPEED).dot(real_vel_y_canceled) / (SPEED ** 2)
	#print(dir_strength)
	
	if is_on_floor() == false:
		#velocity += ((gravity_speed) * camera_global_basis.y * delta) + (abs(slope_y_down) * camera_global_basis.y) #gravity
		velocity += ((gravity_speed) * camera_global_basis.y * delta)
		velocity = velocity.move_toward(Vector3.ZERO, delta * DECCELERATION / 5)
		floor_snap_length = .1
		air_time += delta
		state = "airborne"
	else:
		can_apply_floor_snap = true
		floor_snap_length = .5
		velocity = velocity.move_toward(Vector3.ZERO, delta * DECCELERATION)
		air_time = 0
		can_jump = JUMP_TOTAL
		state = "grounded"
	
	if Input.is_action_just_pressed("Jump") and can_jump > 0:
		can_apply_floor_snap = false
		velocity += ((JUMP_VELOCITY + abs(min(c_local_velocity.y, 0))) * abs(gravity_rotation_node.quaternion.dot(self.quaternion))**10) * self.global_basis.y
		can_jump -= 1
		state = "jumped"
	if Input.is_action_just_released("Jump") and can_jump >= 0: #variable jump height. Cancels local y up
		var jump_peak_delta = abs(JUMP_VELOCITY / gravity_speed)
		if time_going_up < jump_peak_delta:
			velocity -= (gravity_direction * gravity_speed * (jump_peak_delta - time_going_up)) / 2
		if can_jump == 0:
			can_jump -= 1
	
	if Input.is_action_pressed("Jump"): #variable jump height. Gets how long player is holding jump
		time_going_up += delta
	else:
		time_going_up = 0
	
	_get_movement_input()
	_add_platform_velocity()
	if is_on_floor() or floor_col_check_node.is_colliding():
		_ground_movement(delta, 1)
		_mesh_rotation(delta, 1)
	else:
		_ground_movement(delta, .3)
		_mesh_rotation(delta, .5)
	gravity_rotation(gravity_direction)
	#velocity += smooth_move + (slope_y_down * camera_global_basis.y) #adds smooth_move after all previous velocity calcs and adds downward slope velocity
	velocity += smooth_move
	velocity = velocity.limit_length(MAX_VELOCITY) #limits maximum velocity
	move_and_slide()
	if can_apply_floor_snap:
		apply_floor_snap()

var smooth_move: Vector3
var platform_velocity: Vector3
var slope_y_down: float
var movement: Vector3 #movement direction based on input and direction
var wall_cancel: Vector3


func _ground_movement(delta, friction):
	var forward = camera_global_basis.z
	var right = camera_global_basis.x
	#var slope: Quaternion
	#if is_on_floor():
		#if get_floor_normal():
			#slope = Quaternion(get_floor_normal(), -gravity_direction)
	#if abs(slope_y_down) > .1:
		#print(slope_y_down)
	movement = forward * input_dir.y * SPEED
	movement += right * input_dir.x * SPEED
	smooth_move = lerp(smooth_move, movement, ACCELERATION * delta * friction) #smooths movement input
	#slope_y_down = min((smooth_move * Basis(slope).y).z, 0) #gets the y downward direction when on a slope. No. I dont know why this works. But it does and thats all that matters
	#position += smooth_move * delta #modifies position for user input movement instead of velocity
	#print(slope_y_down)
	
	
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
	smooth_target_up_direction = smooth_target_up_direction.slerp(target_up_direction, .035 * (1 + (type_convert(is_on_floor(), TYPE_INT) * 3))) #rotation speed
	up_direction = -gravity_direction #sets characterbody3D up direction to the inverse of the gravity direction
	gravity_rotation_node.quaternion = target_up_direction
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

func _get_slope_direction():
	if is_on_floor():
		var slope_dir: Quaternion = Quaternion(get_floor_normal(), camera_global_basis.y).normalized()
		return slope_dir
