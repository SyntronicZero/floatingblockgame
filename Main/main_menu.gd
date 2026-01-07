extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Levels")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass # Replace with function body.
