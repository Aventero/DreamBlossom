@icon("res://Textures/Quest.png")
class_name Quest
extends Timer

signal completed(success)
signal request_completion_check

var quest_name : String
var time : int
var requirements : Dictionary
var running : bool = false

func _init():
	autostart = false
	one_shot = true
	
	# Connect time exceeded
	timeout.connect(Callable(_on_quest_timeout))
	
	# Free self if quest is completed
	completed.connect(queue_free)

func add_requirement(type : Fruit.Type, amount : int) -> void:
	requirements[type] = amount

func remove_requirement(type : Fruit.Type) -> void:
	if requirements.has(type):
		requirements.erase(type)

func is_fruit_required(type : Fruit.Type) -> bool:
	return requirements.has(type)

func get_fruit_amount(type : Fruit.Type) -> int:
	if requirements.has(type):
		return requirements[type]
	return -1

func get_required_fruits() -> Array:
	return requirements.keys()

func check_completion(current_state : Dictionary) -> bool:
	var keys : Array = requirements.keys()
	
	for key in keys:
		# Check if required fruit is there
		if not current_state.has(key):
			completed.emit(false)
			return false
		
		# Check if required fruit amount is reached
		if current_state[key] < requirements[key]:
			completed.emit(false)
			return false
	
	# Stop quest timer
	stop()
	
	# Emit completed event
	completed.emit(true)
	return true

func start_quest():
	start(time)
	running = true

func _on_quest_timeout():
	# Request completion check
	request_completion_check.emit()

func is_running() -> bool:
	return running
