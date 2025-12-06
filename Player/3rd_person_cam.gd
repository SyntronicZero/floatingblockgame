extends Node3D

@onready var free_cam_node: Node3D = $"."
@onready var camera_rotation_x_node: Node3D = $CameraRotationY/CameraRotationX
@onready var camera_rotation_y_node: Node3D = $CameraRotationY
@onready var camera_location_z_node: Node3D = $CameraRotationY/CameraRotationX/CameraLocationZ
@onready var camera_3d: Camera3D = $SmoothCamera/Camera3D
@onready var cam_wall_detection: RayCast3D = $CameraRotationY/CameraRotationX/WallDetection
@onready var look_detection_node: RayCast3D = $CameraRotationY/CameraRotationX/LookDetection


var cam_basis: Basis
var cam_global_basis: Basis

var input_dir: Vector2
@export var cam_lerp_node: Marker3D
@export var MOUSE_SENSITIVITY: float = .003
@export var CONTROLLER_SENSITIVITY: float = 0.05
@export var fov: float
@export var zoom: float = 0.5:
	set(new_value):
		zoom =  max(new_value, 0.5)
		#camera_location_z_node.position.z = lerp(camera_location_z_node.position.z, zoom, .1)


var camera_rotation: Vector2:
	set(new_value):
		camera_rotation = new_value
		camera_rotation_x_node.rotation.x = camera_rotation.x
		camera_rotation_y_node.rotation.y = camera_rotation.y
		cam_basis = camera_rotation_y_node.basis
		cam_global_basis = camera_rotation_y_node.global_basis

func _ready() -> void:
	if cam_lerp_node != null:
		self.top_level = true

func _physics_process(delta: float) -> void:
	if cam_lerp_node != null:
		transform = lerp(transform, cam_lerp_node.global_transform, .3)
	#camera_location_z_node.position.z = lerp(camera_location_z_node.position.z, zoom, .1)
	#cam_wall_detection.target_position.z = zoom
	_camera_wall_collision()
	_camera_movement(camera_rotation, input_dir)
	cam_basis = camera_rotation_y_node.basis
	cam_global_basis = camera_rotation_y_node.global_basis

func _input(event: InputEvent) -> void:
	input_dir = Input.get_vector("Cont Look Left", "Cont Look Right", "Cont Look Up", "Cont Look Down")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: #mouse camera movement
		camera_rotation.y += (-event.relative.x * MOUSE_SENSITIVITY)
		camera_rotation.x += (-event.relative.y * MOUSE_SENSITIVITY)
		camera_rotation.x = clamp(camera_rotation.x, deg_to_rad(-90), deg_to_rad(90))
		#print("rotating")

func _camera_movement(camera_rot_var, input_vector) -> void:
	if input_vector: #controller input
		camera_rotation.y += (-input_vector.x * CONTROLLER_SENSITIVITY) 
		camera_rotation.x += (-input_vector.y * CONTROLLER_SENSITIVITY)
		camera_rotation.x = clamp(camera_rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _camera_wall_collision():
	var hit_length: float
	cam_wall_detection.target_position.z = zoom + 1
	if cam_wall_detection.is_colliding():
		hit_length = cam_wall_detection.global_position.distance_to(cam_wall_detection.get_collision_point()) - 1
	else:
		hit_length = zoom
	camera_location_z_node.position.z = min(lerp(camera_location_z_node.position.z, zoom, .1), hit_length)
	
