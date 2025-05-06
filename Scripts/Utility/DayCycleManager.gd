class_name DayCycleManager
extends Node3D

signal day_started
signal day_ended
signal hour_progressed(current_hour)

@export var day_night_cycle: DayNightCycle
var _total_order_time: float = 0
var _is_stoppped: bool = true
var _day_completed: bool = false
var _time_of_day: float = 0.0
var _last_hour: int = 0
var _day_progress: float = 0.0
var time_tweener: Tween

func setup():
	_total_order_time = GameBase.level.day_length

func reset_day():
	_total_order_time = 0
	_is_stoppped = true
	_time_of_day = 0.0
	_day_progress = 0.0
	_day_completed = false

func stop_day():
	_is_stoppped = true
	
func start_day():
	# Make sure there is no tweening going on
	if time_tweener and time_tweener.is_valid():
		time_tweener.kill()
		
	print("Start day, total time: ", _total_order_time / 60.0, " minutes")
	_is_stoppped = false
	day_started.emit()

func set_day_start_time(time_of_day: float) -> void:
	# Set a time from 0 - 24 (6 = morning)
	day_night_cycle.time_of_day = time_of_day

func get_day_progress() -> float:
	return _day_progress

func _process(delta):
	if _is_stoppped: return
	var time_increment = (24.0 / _total_order_time) * delta
	
	# update day based on all order times
	day_night_cycle.time_of_day += time_increment
	
	# check once the day is over (player wins the level) 
	_time_of_day += time_increment
	_day_progress = _time_of_day / 24.0
	
	var current_hour: int = floor(_time_of_day)
	if current_hour != _last_hour:
		_last_hour = current_hour
		hour_progressed.emit(current_hour)
		print("Hour progressed current:", current_hour)
	
	if _day_progress >= 1.0 and not _day_completed:
		_day_completed = true
		day_ended.emit()

func tween_to_time(start_time: float, end_time: float, duration: float) -> void:
	if time_tweener and time_tweener.is_valid():
		time_tweener.kill()
	time_tweener = create_tween()
	time_tweener.tween_property(day_night_cycle, "time_of_day", end_time, duration).from(start_time)
