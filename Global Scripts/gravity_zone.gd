extends Area3D

@export var gravity_path: Path3D
var transformed_curve: Curve3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self is Area3D:
		self.connect("body_entered", _body_entered)
		self.connect("body_exited", _body_exited)
		if gravity_path != null:
			gravity_path.top_level = true
			gravity_path.global_position = self.global_position
			
			#transformed_curve = GravityFunctions.transform_curve_points(gravity_path.curve, get_parent_node_3d())

func _body_entered(body:Node3D):
	if "gravity_zones" in body:
		body.gravity_zones.append(self)

func _body_exited(body: Node3D):
	if "gravity_zones" in body:
		body.gravity_zones.erase(self)
