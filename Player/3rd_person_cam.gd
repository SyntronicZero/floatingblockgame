extends Node3D

@onready var free_cam_node: Node3D = $"."
@onready var camera_rotation_x_node: Node3D = $CameraRotationY/CameraRotationX
@onready var camera_rotation_y_node: Node3D = $CameraRotationY
@onready var camera_location_z_node: Node3D = $CameraRotationY/CameraRotationX/CameraLocationZ
@onready var camera_3d: Camera3D = $SmoothCamera/Camera3D

var cam_basis: Basis

var input_dir: Vector2
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
		cam_basis = camera_rotation_y_node.global_basis

func _physics_process(delta: float) -> void:
	camera_location_z_node.position.z = lerp(camera_location_z_node.position.z, zoom, .1)
	_camera_movement(camera_rotation, input_dir)

func _input(event: InputEvent) -> void:
	input_dir = Input.get_vector("Cont Look Left", "Cont Look Right", "Cont Look Up", "Cont Look Down")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: #mouse camera movement
		camera_rotation.y += (-event.relative.x * MOUSE_SENSITIVITY)
		camera_rotation.x += (-event.relative.y * MOUSE_SENSITIVITY)
		camera_rotation.x = clamp(camera_rotation.x, deg_to_rad(-90), deg_to_rad(90))
		#print("rotating")

func _camera_movement(camera_rot_var, input_vector):
	if input_vector: #controller input
		camera_rotation.y += (-input_vector.x * CONTROLLER_SENSITIVITY) 
		camera_rotation.x += (-input_vector.y * CONTROLLER_SENSITIVITY)
		camera_rotation.x = clamp(camera_rotation.x, deg_to_rad(-90), deg_to_rad(90))
