@tool
extends Node3D

# Time of day (0-23)
@export_range(0.0, 24.0, 1.0) var time_of_day: float = 0.0:
	set(value):
		time_of_day = value
		_update_clock_rotation(value)

# Reference to the clock hand mesh
@export var clock_hand: Node3D
@export var day_cycle_manager: DayCycleManager

func _ready():
	if clock_hand:
		_update_clock_rotation(0)

func _update_clock_rotation(hour: float):
	# For a 24-hour clock, each hour represents 15 degrees (360/24)
	var angle = hour * (360.0 / 24.0)
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# First squish down and widen
	tween.tween_property(clock_hand, "scale", Vector3(0.9, 1.5, 0.9), 0.4)
	
	# Snap Hand
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(clock_hand, "rotation", Vector3(0, -deg_to_rad(angle), 0), 0.1)
	tween.parallel().tween_property(clock_hand, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
	tween.tween_property(clock_hand, "scale", Vector3(1.0, 1.0, 1.0), 0.1) # scale back
	
	# Squish clock
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector3(1.01, 1.0, 1.01), 0.1)
	tween.tween_property(self, "scale", Vector3(0.99, 1.0, 0.99), 0.2)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.2)
	
func _on_day_cycle_manager_hour_progressed(current_hour: Variant) -> void:
	print("_update", current_hour)
	_update_clock_rotation(int(current_hour))
	set_escape_sprite(int(current_hour))

func set_escape_sprite(current_hour: int) -> void:
	match current_hour:
		0, 1, 2, 3, 4, 5:
			$EscapeSprite.frame = 6
		6, 7, 8, 9, 10:
			$EscapeSprite.frame = 5
		11, 12, 13, 14, 15:
			$EscapeSprite.frame = 4
		16, 17, 18:
			$EscapeSprite.frame = 3
		19, 20, 21:
			$EscapeSprite.frame = 2
		22, 23:
			$EscapeSprite.frame = 1
		24, 25:
			$EscapeSprite.frame = 0

func _on_day_cycle_manager_day_started() -> void:
	$EscapeSprite.play()
