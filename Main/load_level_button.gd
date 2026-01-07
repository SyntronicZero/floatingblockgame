extends Button

@export var level_to_load: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("button_up", _on_button_pressed)
	pass # Replace with function body.


func _on_button_pressed():
	if LoadFunctions.level_loading_node != null:
		LoadFunctions.level_loading_node.begin_level_load(level_to_load)
	
	pass
