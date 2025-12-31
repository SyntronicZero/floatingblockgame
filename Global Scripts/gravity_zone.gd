extends Area3D

##Original Path. Set in planet scene.
@export var reference_gravity_path: Path3D
##Unique Path. Set in scene if object will be transformed via scaling or rotation. Will use the Reference Path to generate a new path.
@export var unique_gravity_path: Path3D 
var gravity_path: Path3D
##Will update curve points dynamically if 
@export var moving_path: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self is Area3D:
		self.connect("body_entered", _body_entered)
		self.connect("body_exited", _body_exited)
		if reference_gravity_path != null:
			reference_gravity_path.top_level = true
			reference_gravity_path.global_position = self.global_position
			if unique_gravity_path == null:
				gravity_path = reference_gravity_path
			else:
				unique_gravity_path.top_level = true
				unique_gravity_path.scale = Vector3.ONE
				unique_gravity_path.global_rotation = Vector3.ZERO
				gravity_path = unique_gravity_path
				GravityFunctions.transform_curve_points(unique_gravity_path, reference_gravity_path)
			#transformed_curve = GravityFunctions.transform_curve_points(reference_gravity_path.curve, get_parent_node_3d())

func _physics_process(_delta: float) -> void:
	if moving_path:
		reference_gravity_path.transform = self.transform
		unique_gravity_path.position = self.global_position
		GravityFunctions.transform_curve_points(unique_gravity_path, reference_gravity_path)

func _body_entered(body:Node3D):
	if "gravity_zones" in body:
		body.gravity_zones.append(self)

func _body_exited(body: Node3D):
	if "gravity_zones" in body:
		body.gravity_zones.erase(self)
