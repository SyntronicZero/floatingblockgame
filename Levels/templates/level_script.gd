extends Node3D

@export var level_name: String

#signal level_change_requested(path_to_level)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Levels")
	
	pass # Replace with function body.

#func change_to_requested_level(path: String) -> void:
	#emit_signal("level_change_requested", path)
