extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		LoadFunctions.level_loading_node.begin_level_load("res://Main/main_menu.tscn")
	pass # Replace with function body.
