@tool
extends Node3D
@export var rotation_speed: float = 1
@export var rotation_direction: Vector3 = Vector3(0, 0, 0)
# Called when the node enters the scene tree for the first time.


func _physics_process(delta: float) -> void:
	if rotation_direction:
		quaternion = Quaternion(rotation_direction.normalized(), rotation_speed * delta) * quaternion
