extends CanvasLayer

@onready var respawn_swipe_player: AnimationPlayer = $RespawnSwipePlayer
@onready var player: CharacterBody3D = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


func begin_respawn() -> void: #begins respawning process
	respawn_swipe_player.play("Screen_Swipe")
	pass

func respawn_player() -> void: #called from animation player when screen is completely obscured
	player.is_respawning = true
	pass
