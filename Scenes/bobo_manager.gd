extends Node3D

@export var bobo_follower: BoboFollower
@export var bobo: Bobo


# Make bobo walk in and do what tutorial did for the start
func _ready() -> void:
	bobo_follower.move_bobo(0.5, 1.0)

# Start first order
func _on_bobo_bobo_sat_down() -> void:
	bobo.hit_shield()

func _on_bobo_path_follow_3d_bobo_done_moving() -> void:
	bobo.sit_down()
	
