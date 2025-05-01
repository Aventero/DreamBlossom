extends PathFollow3D
class_name BoboFollower

@export var bobo: Node3D
signal bobo_done_moving
var signal_emitted = false
	
func move_bobo(from: float, to: float) -> void:
	signal_emitted = false
	
	# Set initial position
	progress_ratio = from
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(update_progress, from, to, 20.0)

func update_progress(value: float) -> void:
	progress_ratio = value
	
	# Emit the signal when we reach 90% of the path
	if progress_ratio >= 0.9 and not signal_emitted:
		signal_emitted = true
		bobo_done_moving.emit()
