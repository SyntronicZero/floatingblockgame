extends Area3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@onready var respawn_point: Marker3D = $RespawnPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("body_entered", _set_player_respawn)
	mesh_instance_3d.set_surface_override_material(0, mesh_instance_3d.get_active_material(0).duplicate())
	pass # Replace with function body.


func _set_player_respawn(body: Node3D) -> void:
	if "respawn" in body:
		body.respawn = respawn_point
		var material = mesh_instance_3d.get_surface_override_material(0)
		material.emission_energy_multiplier = 1
