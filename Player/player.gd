extends CharacterBody3D

@export var camera_node: Node3D
var camera_basis: Basis

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
	direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		##velocity.x = direction.x * SPEED 
		##velocity.z = direction.z * SPEED
		#_ground_movement(delta)
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
		#pass
	if is_on_floor():
		_ground_movement(delta, 1)
	else:
		_ground_movement(delta, .3)
	move_and_slide()

func _ground_movement(delta, friction):
	if input_dir:
		velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta * friction) #move when input
		velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta * friction)
	else:
		velocity.x = lerp(velocity.x, 0.0, ACCELERATION * delta * friction) #slow to stop when not moving
		velocity.z = lerp(velocity.z, 0.0, ACCELERATION * delta * friction)
