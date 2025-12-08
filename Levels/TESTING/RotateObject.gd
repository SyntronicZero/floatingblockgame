extends AnimatableBody3D

@export var rotation_speed: float
@export var rotation_direction: Vector3
# Called when the node enters the scene tree for the first time.

func _physics_process(_delta: float) -> void:
	quaternion = Quaternion(rotation_direction.normalized(), rotation_speed) * quaternion
