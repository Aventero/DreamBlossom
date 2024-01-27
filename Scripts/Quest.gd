@icon("res://Textures/Quest.png")
class_name Quest
extends Timer

signal success;
signal failed;
signal completed;

var quest_name : String
var time : int
var requirements : Dictionary
var running : bool = false

func _init():
	autostart = false
	one_shot = true
	
	# Connect time exceeded
	timeout.connect(Callable(_on_quest_timeout))

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
			return false
		
		# Check if required fruit amount is reached
		if current_state[key] < requirements[key]:
			return false
	
	# Stop quest timer
	stop()
	
	# Emit completed event
	success.emit()
	completed.emit()
	return true

func start_quest():
	start(time)
	running = true

func _on_quest_timeout():
	# Delete quest node
	failed.emit()
	completed.emit()
	queue_free()

func is_running() -> bool:
	return running
