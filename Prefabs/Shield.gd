@tool
class_name Shield
extends Node3D
@export var curve: Curve
@export_tool_button("hit_shield 2") var hit_shield_02 = shield_hit
@export_tool_button("start_ambient_motion") var start_ambient = start_ambient_motion
@export_tool_button("stop_ambient_motion") var stop_ambient = stop_ambient_motion

var ambient_tween: Tween
var shield_hit_tween: Tween

func _ready() -> void:
	start_ambient_motion()

func tween_curve(v) -> float:
	return curve.sample_baked(v)

func shield_hit() -> void:
	if ambient_tween and ambient_tween.is_valid(): ambient_tween.kill()
	if shield_hit_tween and shield_hit_tween.is_valid(): shield_hit_tween.kill()
	
	# Create the first tween for the forward motion
	shield_hit_tween = create_tween()
	# Chain curl effect - rotate each chain link
	var curl_step = 2.0
	var curl_time = 0.8
	shield_hit_tween.set_parallel(true)
	shield_hit_tween.tween_property($Chain_0, "rotation_degrees:x", curl_step, curl_time).set_custom_interpolator(tween_curve)
	shield_hit_tween.tween_property($Chain_0/Chain_1, "rotation_degrees:x", curl_step * 3, curl_time).set_custom_interpolator(tween_curve)
	shield_hit_tween.tween_property($Chain_0/Chain_1/Chain_2, "rotation_degrees:x", curl_step * 5, curl_time).set_custom_interpolator(tween_curve)
	shield_hit_tween.tween_property($Chain_0/Chain_1/Chain_2/Chain_3, "rotation_degrees:x", curl_step * 7, curl_time).set_custom_interpolator(tween_curve)
	shield_hit_tween.tween_property($Chain_0/Chain_1/Chain_2/Chain_3/Shield, "rotation_degrees:x", curl_step * 10, curl_time).set_custom_interpolator(tween_curve)
	shield_hit_tween.set_parallel(false)
	shield_hit_tween.tween_interval(0.01)
	
	# Add the reverse motion to the same tween chain
	var reverse = shield_hit_tween.chain()
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
	reverse.set_parallel(false)
	reverse.tween_callback(start_ambient_motion)

func start_ambient_motion() -> void:
	# Kill any existing ambient tween
	if ambient_tween and ambient_tween.is_valid():
		ambient_tween.kill()
	
	# Create a new looping tween
	ambient_tween = create_tween()
	ambient_tween.set_loops() # Infinite loops
	
	# Small subtle movements
	var sway_amount = 0.3 # Small rotation
	var sway_time = 4.0 # Slow movement
	
	# Forward sway
	sway(sway_amount, sway_time, 1)
	sway(sway_amount, sway_time, -1)

func sway(sway_amount: float, sway_time: float, forward_dir: int) -> void:
	forward_dir = sign(forward_dir)
	ambient_tween.set_ease(Tween.EASE_IN_OUT)
	ambient_tween.set_trans(Tween.TRANS_SINE)
	ambient_tween.tween_property($Chain_0, "rotation_degrees:x", sway_amount * forward_dir, sway_time)
	ambient_tween.parallel().tween_property($Chain_0/Chain_1, "rotation_degrees:x", sway_amount * forward_dir * 1.5, sway_time)
	ambient_tween.parallel().tween_property($Chain_0/Chain_1/Chain_2, "rotation_degrees:x", sway_amount * forward_dir * 2, sway_time)
	ambient_tween.parallel().tween_property($Chain_0/Chain_1/Chain_2/Chain_3, "rotation_degrees:x", sway_amount * forward_dir * 2.5, sway_time)
	ambient_tween.parallel().tween_property($Chain_0/Chain_1/Chain_2/Chain_3, "rotation_degrees:z", sway_amount * forward_dir * 3, sway_time)
	ambient_tween.parallel().tween_property($Chain_0/Chain_1/Chain_2/Chain_3/Shield, "rotation_degrees:x", sway_amount * forward_dir * 3, sway_time)
	ambient_tween.parallel().tween_property($Chain_0/Chain_1/Chain_2/Chain_3/Shield, "rotation_degrees:y", sway_amount * forward_dir * 0.3, sway_time)
	ambient_tween.parallel().tween_property($Chain_0/Chain_1/Chain_2/Chain_3/Shield, "rotation_degrees:z", sway_amount * forward_dir * 3, sway_time)

func stop_ambient_motion() -> void:
	if ambient_tween and ambient_tween.is_valid():
		ambient_tween.kill()
		
	# Reset all rotations to zero
	var reset_tween = create_tween()
	reset_tween.set_parallel(true)
	reset_tween.set_ease(Tween.EASE_OUT)
	reset_tween.set_trans(Tween.TRANS_SINE)
	
	reset_tween.tween_property($Chain_0, "rotation_degrees:x", 0.0, 1.0)
	reset_tween.tween_property($Chain_0/Chain_1, "rotation_degrees:x", 0.0, 1.0)
	reset_tween.tween_property($Chain_0/Chain_1/Chain_2, "rotation_degrees:x", 0.0, 1.0)
	reset_tween.tween_property($Chain_0/Chain_1/Chain_2/Chain_3, "rotation_degrees:x", 0.0, 1.0)
	reset_tween.tween_property($Chain_0/Chain_1/Chain_2/Chain_3, "rotation_degrees:z", 0.0, 1.0)
	reset_tween.tween_property($Chain_0/Chain_1/Chain_2/Chain_3/Shield, "rotation_degrees:x", 0.0, 1.0)
	reset_tween.tween_property($Chain_0/Chain_1/Chain_2/Chain_3/Shield, "rotation_degrees:y", 0.0, 1.0)
	reset_tween.tween_property($Chain_0/Chain_1/Chain_2/Chain_3/Shield, "rotation_degrees:z", 0.0, 1.0)
