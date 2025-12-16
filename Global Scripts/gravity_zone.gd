extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self is Area3D:
		self.connect("body_entered", _body_entered)
		self.connect("body_exited", _body_exited)

func _body_entered(body:Node3D):
	if "gravity_zones" in body:
		body.gravity_zones.append(self)

func _body_exited(body: Node3D):
	if "gravity_zones" in body:
		body.gravity_zones.erase(self)
