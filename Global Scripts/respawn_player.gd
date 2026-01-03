extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func player_safe_pos_respawn(player: CharacterBody3D, distance: float, safe_pos: Vector3) -> void:
	var dis_from_safe: float = (player.global_position - safe_pos).length()
	if dis_from_safe > distance:
		player.global_position = safe_pos
		player.velocity = Vector3.ZERO
	pass
