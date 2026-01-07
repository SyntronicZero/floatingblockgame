extends Node

@onready var loading_screen: AnimationPlayer = $"../LoadingScreen/LoadingScreenPlayer"

@onready var current_level: Node
var next_level: Node
var requested_level: String
var load_started: bool
var loading_level: bool
var load_progress: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LoadFunctions.level_loading_node = self
	current_level = get_tree().get_nodes_in_group('Levels').get(0)
	print(current_level)
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if loading_level:
		_change_to_level(requested_level)

func _change_to_level(path: String) -> void:
	ResourceLoader.load_threaded_get_status(path, load_progress)
	if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		loading_level = false
		next_level = ResourceLoader.load_threaded_get(path).instantiate()
		self.add_child(next_level)
		current_level = next_level
		next_level = null
		loading_screen.play("Fade_Out")

func begin_level_load(path: String) -> void: #begins loading level at a given path
	if load_started or !path.ends_with(".tscn"): #checks if its already loading a level and if the path ends in .tscn
		return
	load_started = true
	current_level.call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED) #disables processing of the nodes when loading. "call_deferred" means it will call at the end of a physics process
	loading_screen.play("Fade_In")
	requested_level = path
	ResourceLoader.load_threaded_request(path)


func _on_loading_screen_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Fade_In":
			current_level.queue_free()
			loading_level = true
		"Fade_Out":
			load_started = false
