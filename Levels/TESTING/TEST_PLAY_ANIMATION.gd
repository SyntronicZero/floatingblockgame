extends AnimatableBody3D

@export var anim_player: AnimationPlayer
@export var animation: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.play(animation)
	pass # Replace with function body.
