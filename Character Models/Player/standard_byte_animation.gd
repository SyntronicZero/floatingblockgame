extends Node3D

@export var c_node: Node3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
@onready var jump_player: AudioStreamPlayer3D = $JumpPlayer

var default_walk_sounds: Array
var jump_sounds: Array


var smoothed_y: float = 0.00
var state: String:
	set(value):
		#if state == "jumped":
			#print("jump sound")
			#jump_player.set_stream(jump_sounds.pick_random())
			#jump_player.set_volume_linear(.1)
			#jump_player.play(.23)
			#pass
		state = value
		pass
var movement_strength: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	default_walk_sounds.assign(LoadFunctions.load_folder("res://Audio/Sounds/Walking/Default/", ".ogg"))
	jump_sounds.assign(LoadFunctions.load_folder("res://Audio/Sounds/Jumping/", ".ogg"))
	print(default_walk_sounds)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movement_strength = remap(c_node.smooth_move.length(), 0, c_node.SPEED, 0, 1)
	state = c_node.state
	var y_vel: float = c_node.c_local_velocity.y
	smoothed_y = lerp(smoothed_y, y_vel / 5, 10 *  delta)
	if state == "grounded":
		animation_tree.get("parameters/playback").travel("Idle-Run") #gets the current animation, then changes it to the desired one?
		animation_tree.set("parameters/Idle-Run/RunBlend/blend_amount", min(abs(c_node.smooth_move.length()) / c_node.SPEED, 1))
	if state == "airborne":
		animation_tree.get("parameters/playback").travel("Airborne")
		animation_tree.set("parameters/Airborne/Blend2/blend_amount", remap(clamp(smoothed_y + .1, -1 , 1), 1, -1, 0, 1))

func footstep_audio(ground_type: String = "Default"):
	var volume_strength: float = (movement_strength ** 2) / 7.5
	if volume_strength > 0.01:
		footstep_player.set_volume_linear(min(volume_strength, .05))
		if c_node.state == "grounded":
			if ground_type == "Default":
				footstep_player.set_stream(default_walk_sounds.pick_random())
				footstep_player.play()
				pass
	else:
		footstep_player.stop()
	pass
