@tool
extends Node3D
@export var curve: Curve
@export_tool_button("hit_shield 2") var hit_shield_02 = shield_hit

func tween_curve(v) -> float:
	return curve.sample_baked(v)

func shield_hit() -> void:
	# Create the first tween for the forward motion
	var tween = create_tween()
	# Chain curl effect - rotate each chain link
	var curl_step = 2.0
	var curl_time = 0.8
	tween.set_parallel(true)
	tween.tween_property($Chain_0, "rotation_degrees:x", curl_step, curl_time).set_custom_interpolator(tween_curve)
	tween.tween_property($Chain_0/Chain_1, "rotation_degrees:x", curl_step * 3, curl_time).set_custom_interpolator(tween_curve)
	tween.tween_property($Chain_0/Chain_1/Chain_2, "rotation_degrees:x", curl_step * 5, curl_time).set_custom_interpolator(tween_curve)
	tween.tween_property($Chain_0/Chain_1/Chain_2/Chain_3, "rotation_degrees:x", curl_step * 7, curl_time).set_custom_interpolator(tween_curve)
	tween.tween_property($Chain_0/Chain_1/Chain_2/Chain_3/Shield, "rotation_degrees:x", curl_step * 10, curl_time).set_custom_interpolator(tween_curve)
	tween.set_parallel(false)
	tween.tween_interval(0.01)
	
	# Add the reverse motion to the same tween chain
	var reverse = tween.chain()
	reverse.set_parallel(true)
	reverse.set_trans(Tween.TRANS_ELASTIC)
	reverse.set_ease(Tween.EASE_OUT)
	
	# Reverse animation returning all parts to zero
	curl_time = 3.0
	reverse.tween_property($Chain_0/Chain_1/Chain_2/Chain_3/Shield, "rotation_degrees:x", 0.0, curl_time)
	reverse.tween_property($Chain_0/Chain_1/Chain_2/Chain_3, "rotation_degrees:x", 0.0, curl_time)
	reverse.tween_property($Chain_0/Chain_1/Chain_2, "rotation_degrees:x", 0.0, curl_time)
	reverse.tween_property($Chain_0/Chain_1, "rotation_degrees:x", 0.0, curl_time)
	reverse.tween_property($Chain_0, "rotation_degrees:x", 0.0, curl_time)
