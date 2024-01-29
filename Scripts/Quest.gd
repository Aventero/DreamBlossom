@icon("res://Textures/Quest.png")
class_name Quest
extends Timer

signal completed(success)
signal request_completion_check

@export var quest_name : String
@export var time : int
@export var requirements : Array[QuestRequirement]

var _requirements_lookup : Dictionary

func _ready():
	autostart = false
	one_shot = true
	
	# Connect time exceeded
	timeout.connect(Callable(_on_quest_timeout))
	
	# Free self if quest is completed
	completed.connect(queue_free)
	
	# Fill lookup
	for requirement in requirements:
		_requirements_lookup[requirement.type] = requirement.amount

func is_fruit_required(type : Fruit.Type) -> bool:
	return requirements.has(type)

func get_fruit_amount(type : Fruit.Type) -> int:
	if _requirements_lookup.has(type):
		return _requirements_lookup[type]
	return -1

func get_required_fruits() -> Array:
	return _requirements_lookup.keys()

func check_completion(current_state : Dictionary) -> bool:
	var keys : Array = _requirements_lookup.keys()
	
	for key in keys:
		# Check if required fruit is there
		if not current_state.has(key):
			completed.emit(false)
			return false
		
		# Check if required fruit amount is reached
		if current_state[key] < _requirements_lookup[key]:
			completed.emit(false)
			return false
	
	# Stop quest timer
	stop()
	
	# Emit completed event
	completed.emit(true)
	return true

func start_quest():
	start(time)

func _on_quest_timeout():
	# Request completion check
	request_completion_check.emit()
