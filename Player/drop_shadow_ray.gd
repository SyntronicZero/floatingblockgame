extends RayCast3D
@onready var drop_shadow_point: Marker3D = $DropShadowPoint
@onready var gravity_rotation: Node3D = $".."
@onready var drop_decal: Decal = $DropShadow/DropDecal

func _ready() -> void:
	drop_shadow_point.top_level = true

var shadow_opacity: float
# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	var collision_distance: float = (self.global_position - self.get_collision_point()).length()
	print(collision_distance)
	if is_colliding():
		#if collision_distance > 3:
			#shadow_opacity = lerp(shadow_opacity, 1.0, 5 * delta)
		#else:
			#shadow_opacity = lerp(shadow_opacity, 0.0, 20 * delta)
		if collision_distance > (abs(target_position.y) - 3):
			shadow_opacity = clamp(remap(collision_distance, (abs(target_position.y) - 3), abs(target_position.y), 1.0, 0.0), 0.0, 1.0)
		else: 
			shadow_opacity = clamp(remap(collision_distance, 2.0, abs(target_position.y) - 4, 0.0, 1.0), 0.0, 1.0)
		drop_shadow_point.global_position = self.get_collision_point()
		#shadow_opacity = lerp(shadow_opacity, max(remap(collision_distance, 2.0, abs(target_position.y), 0.0, 1.0), 0.0), .5)
	else:
		shadow_opacity = 0
	drop_decal.modulate.a = shadow_opacity
	drop_shadow_point.quaternion = gravity_rotation.quaternion
