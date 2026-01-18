extends Node


var checkpoint_pos: Vector3
var respawn_node: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func is_player_too_far(player: CharacterBody3D, distance: float, safe_pos: Vector3) -> bool:
	var dis_from_safe: float = (player.global_position - safe_pos).length()
	if dis_from_safe > distance:
		#player.global_position = safe_pos
		#player.velocity = Vector3.ZERO
		return true
	return false

func respawn_at_checkpoint(character_body: CharacterBody3D, point: Node3D) -> void:
	character_body.velocity = Vector3.ZERO
	character_body.transform = point.global_transform
	if "gravity_direction" in character_body:
		character_body.gravity_direction = point.global_basis * Vector3(0, -1, 0)
	if "camera_node" and "gravity_rotation_node" in character_body:
		character_body.gravity_rotation_node.global_transform = character_body.global_transform
		if character_body.camera_node != null:
			character_body.camera_node.resetting = true
			character_body.camera_node.global_transform = character_body.global_transform
	if "smooth_move" in character_body:
		character_body.smooth_move = Vector3.ZERO
	if character_body.has_method("reset_visual_rotations"):
		character_body.reset_visual_rotations()
