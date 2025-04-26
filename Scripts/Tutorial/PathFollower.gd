extends PathFollow3D

class_name BoboFollower
@export var bobo: Node3D

signal bobo_done_moving

	
func move_bobo(from: float, to: float) -> void:
	progress_ratio = from
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "progress_ratio", to, 10.0)
	tween.tween_callback(bobo_done_moving.emit.bind())
