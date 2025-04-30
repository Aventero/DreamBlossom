#@icon("res://Textures/Order.png")
class_name Order
extends Timer

signal completed(success)
signal request_update(current_ingredients)

@export var time : int
@export var requirements : Array[OrderRequirement]

var _running : bool = false
var _requirements_lookup : Dictionary
var _given_ingredients : Dictionary

func _ready():
	# Setup order timer
	autostart = false
	one_shot = true

	# Connect order failed event
	timeout.connect(_on_order_timeout)

	# Fill lookup
	for requirement in requirements:
		_requirements_lookup[requirement.type] = requirement.amount

func start_order():
	start(time)
	_running = true

func _on_order_timeout():
	completed.emit(false)
	queue_free()

func is_required(type : Ingredient.Type) -> bool:
	return _requirements_lookup.has(type)

func progress_order(type : Ingredient.Type) -> void:
	var update : bool = false

	# Update given ingredients dictionary
	if not _given_ingredients.has(type):
		_given_ingredients[type] = 1
		update = true
	elif _requirements_lookup[type] > _given_ingredients[type]:
		_given_ingredients[type] += 1
		update = true

	if update:
		request_update.emit(_given_ingredients)

	# Check if order is complete
	if _given_ingredients == _requirements_lookup:
		await get_tree().create_timer(1.0).timeout
		completed.emit(true)
		queue_free()

func get_ingredient_amount(type : Ingredient.Type) -> int:
	if _requirements_lookup.has(type):
		return _requirements_lookup[type]
	return -1

func get_remaining_amount(type : Ingredient.Type) -> int:
	if not _requirements_lookup.has(type):
		return -1
	
	if _given_ingredients.has(type):
		return _requirements_lookup[type] - _given_ingredients[type]
	else:
		return _requirements_lookup[type]

func is_running() -> bool:
	return _running
