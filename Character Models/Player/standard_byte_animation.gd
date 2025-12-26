extends Node3D

@export var c_node: Node3D
@onready var animation_tree: AnimationTree = $AnimationTree

var smoothed_y: float = 0.00
var state: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	state = c_node.state
	var y_vel: float = c_node.c_local_velocity.y
	smoothed_y = lerp(smoothed_y, y_vel / 5, 10 *  delta)
	if state == "grounded":
		animation_tree.get("parameters/playback").travel("Idle-Run") #gets the current animation, then changes it to the desired one?
		animation_tree.set("parameters/Idle-Run/RunBlend/blend_amount", min(abs(c_node.smooth_move.length()) / c_node.SPEED, 1))
	if state == "airborne":
		animation_tree.get("parameters/playback").travel("Airborne")
		animation_tree.set("parameters/Airborne/Blend2/blend_amount", remap(clamp(smoothed_y + .1, -1 , 1), 1, -1, 0, 1))
