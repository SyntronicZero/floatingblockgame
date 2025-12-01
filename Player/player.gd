extends CharacterBody3D

#region Nodes
@onready var mesh_rotation_y_node: Node3D = $MeshRotationY
@onready var mesh_rotation_z_node: Node3D = $MeshRotationY/MeshRotationZ
#endregion

@export var camera_node: Node3D
var camera_basis: Basis

const MESH_ROTATION_SPEED = 15.0
var _theta: float
const ACCELERATION = 5.0
const DECCELERATION = 1.0
const SPEED = 7.5
const JUMP_VELOCITY = 4.5

var input_dir: Vector2
var direction: Vector3
func _ready() -> void:
	if camera_node != null:
		camera_basis = camera_node.cam_basis


func _physics_process(delta: float) -> void:
	# Add the gravity.
	camera_basis = camera_node.cam_basis
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	
	direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y))
	if is_on_floor():
		_ground_movement(delta, 1)
		_mesh_rotation(delta, 1)
	else:
		_ground_movement(delta, .3)
		_mesh_rotation(delta, .5)
	move_and_slide()

func _ground_movement(delta, friction):
	if input_dir:
		velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta * friction) #move when input
		velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta * friction)
	else:
		velocity.x = lerp(velocity.x, 0.0, ACCELERATION * delta * friction) #slow to stop when not moving
		velocity.z = lerp(velocity.z, 0.0, ACCELERATION * delta * friction)

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
		print("rotata")
#clamp(_theta, -deg_to_rad(25), deg_to_rad(25))
