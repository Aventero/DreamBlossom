@tool
extends Node3D

# Time of day (0-23)
@export_range(0.0, 24.0, 1.0) var time_of_day: float = 0.0:
	set(value):
		time_of_day = value
		_update_clock_rotation()

# Reference to the clock hand mesh
@export var clock_hand: Node3D

func _ready():
	if clock_hand:
		_update_clock_rotation()

func _update_clock_rotation():
	# For a 24-hour clock, each hour represents 15 degrees (360/24)
	var angle = time_of_day * 360.0 / 24.0
	clock_hand.rotation.y = -deg_to_rad(angle)

func _process(delta):
	if Engine.is_editor_hint():
		# You can uncomment the below code to see the clock animate in the editor
		# var new_time = fmod(time_of_day + delta * rotation_speed, 24)
		# time_of_day = int(new_time)
		pass
