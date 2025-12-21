extends Label
@onready var player: CharacterBody3D = $"../.."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if "floor_norm_grav" in player:
		self.text = "(L1 to activate) Floor Normal Gravity = " + str(player.floor_norm_grav)
	pass
