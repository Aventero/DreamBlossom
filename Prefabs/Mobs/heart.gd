@tool
extends Node3D
class_name Heart

signal hunger_zero

@export_tool_button("start beating") var beating = start_heartbeat
@export_tool_button("stop beating") var stop_beating = stop_heartbeat
@export_tool_button("hunger") var hungerer = hunger.bind(5)
var is_beating: bool = false
var heartbeat_tween: Tween
var sway_tween: Tween

# Amount from 0 - 1
@export_range(0.0, 100.0, 1.0) var initial_hunger_level: int = 50
@export_range(0.0, 100.0, 1.0) var feed_level: int = 50
@export_range(0.3, 5.0, 0.1) var heartspeed: float = 2.0

func _ready() -> void:
	stop_hunger()
	scale = Vector3(1.0, 1.0, 1.0)
	start_heartbeat()
	start_sway()
	feed_level = initial_hunger_level
	$Heart/HeartFill.set_instance_shader_parameter("fill_percentage", float(feed_level) * 0.01)
	
# TWEENS 
func start_heartbeat() -> void:
	if is_beating:
		return
	
	is_beating = true
	_heartbeat_animation()
	start_sway()

func stop_heartbeat() -> void:
	is_beating = false

func _heartbeat_animation() -> void:
	if not is_beating:
		return
	
	# Create a new tween
	heartbeat_tween = create_tween()
	heartbeat_tween.set_trans(Tween.TRANS_BACK)
	heartbeat_tween.set_ease(Tween.EASE_OUT)
	
	# Original scale - store this if your heart might have a non-uniform scale
	var original_scale = $Heart.scale
	
	# retract
	var time_speed = clamp(heartspeed, 0.7, 1.3)
	# squish
	heartbeat_tween.tween_property($Heart, "scale", original_scale * Vector3(1.1, 0.9, 0.9), 0.15 * time_speed)
	
	# stretch 
	heartbeat_tween.tween_property($Heart, "scale", original_scale * Vector3(0.9, 1.1, 1.05), 0.12 * time_speed)
	
	# squish
	heartbeat_tween.tween_property($Heart, "scale", original_scale * Vector3(1.05, 0.95, 0.95), 0.15 * time_speed)
	
	# Return to original size
	heartbeat_tween.set_ease(Tween.EASE_OUT)
	heartbeat_tween.tween_property($Heart, "scale", original_scale, time_speed * 0.2)
	# Wait period between beats
	heartbeat_tween.tween_interval(heartspeed)
	
	# Chain a callback to continue the heartbeat
	heartbeat_tween.tween_callback(_heartbeat_animation)

func start_sway() -> void:
	if sway_tween and sway_tween.is_valid():
		sway_tween.kill()
		
	sway_tween = create_tween()
	sway_tween.set_loops()
	sway(10.0, 3.0, 1.0)
	sway(10.0, 3.0, -1.0)

func sway(sway_amount: float, sway_time: float, forward_dir: int) -> void:
	forward_dir = sign(forward_dir)
	sway_tween.set_ease(Tween.EASE_IN_OUT)
	sway_tween.set_trans(Tween.TRANS_SINE)
	sway_tween.tween_property($Heart, "rotation_degrees:x", -45.0 + sway_amount * forward_dir, sway_time)

# feeing, amount is out of 100
func feed_heart(amount: int) -> void:
	feed_level += amount
	$Heart/HeartFill.set_instance_shader_parameter("fill_percentage", float(feed_level) * 0.01)
	print("Feeding: ", amount, " to bobo, now at: ", feed_level)

func hunger(amount: int) -> void:
	feed_level -= amount
	$Heart/HeartFill.set_instance_shader_parameter("fill_percentage", float(feed_level) * 0.01)
	print("Hunger: -", amount, " to bobo, now at: ", feed_level)
	if feed_level <= 0:
		hunger_zero.emit()

func start_hunger() -> void:
	$HungerTimer.start()
	
func stop_hunger() -> void:
	$HungerTimer.stop()

func _on_hunger_timer_timeout() -> void:
	hunger(5)

	
