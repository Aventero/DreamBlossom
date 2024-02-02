class_name OrderDisplayUI
extends Panel

signal order_completed

@export var fade_duration : float = 0.5
@export var incoming_duration : float = 2.0
@export var failed_duration : float = 5.0
@export var completed_duration : float = 5.0

@onready var order_screen : Control = $"Order Screen"
@onready var complete_screen : Control = $"Complete Screen"
@onready var failed_screen : Control = $"Failed Screen"
@onready var awaiting_screen : Control = $"Awaiting Screen"
@onready var incoming_screen : Control = $"Incoming Screen"

@onready var order_time : Label = $"Order Screen/MarginContainer/Timer Row/Time"
@onready var order_timer : Slider = $"Order Screen/MarginContainer/Timer Row/Timer"
@onready var seconds_timer : Timer = $"Order Screen/MarginContainer/Timer Row/Seconds"

@onready var ingredient_ui = preload("res://Prefabs/UI/IngredientUI.tscn")

var _current_screen : Control
var _ingredient_lookup : Dictionary

func _ready():
	_current_screen = awaiting_screen

func start_order():
	await _show_screen(incoming_screen).finished
	
	# Wait a bit
	await get_tree().create_timer(incoming_duration).timeout
	
	# Setup order ui
	_setup_order_ui()
	
	await _show_screen(order_screen).finished
	
	# Connect to order events
	LevelManager.order.completed.connect(_on_order_completed)
	LevelManager.order.request_update.connect(_on_update_request)
	
	# Start timer
	seconds_timer.start()
	LevelManager.order.start_order()

func _show_screen(screen : Control):
	var tween : Tween = create_tween().set_parallel(true)
	
	# Fade out previous screen
	tween.tween_property(_current_screen, "modulate", Color(1.0, 1.0, 1.0, 0.0), fade_duration)
	
	# Fade in incoming screen
	tween.tween_property(screen, "modulate", Color(1.0, 1.0, 1.0, 1.0), fade_duration)
	
	_current_screen = screen
	return tween

func _setup_order_ui():
	var order : Order = LevelManager.order
	
	# Order name
	$"Order Screen/Order Name".text = order.name
	
	# Ingredients
	for ingredient in order.requirements:
		_spawn_ingredient_ui(ingredient.type, ingredient.amount)
	
	# Time / Timer
	order_time.text = str(order.time)
	order_timer.max_value = order.time
	order_timer.value = order.time

func _spawn_ingredient_ui(ingredient : Ingredient.Type, amount : int):
	var ingredient_ui : IngredientUI = ingredient_ui.instantiate()
	$"Order Screen/Ingredients".add_child(ingredient_ui)
	
	# Fill ingredient ui with data
	ingredient_ui.set_icon(TextureLoader.get_instance().get_ingredient_icon(ingredient))
	ingredient_ui.set_amount(amount)
	
	_ingredient_lookup[ingredient] = ingredient_ui

func _on_order_completed(success : bool):
	if success:
		# Show completed screen
		await _show_screen(complete_screen).finished
		await get_tree().create_timer(completed_duration).timeout
	else:
		# Show failed screen
		await _show_screen(failed_screen).finished
		await get_tree().create_timer(failed_duration).timeout
	
	await _show_screen(awaiting_screen).finished
	order_completed.emit()
	
	# Clear old order screen
	for ingredient in $"Order Screen/Ingredients".get_children():
		ingredient.queue_free()

func _on_update_request(ingredients : Dictionary):
	for ingredient in ingredients:
		var ingredient_ui : IngredientUI = _ingredient_lookup[ingredient]
		var difference : int = LevelManager.order.get_remaining_amount(ingredient)
		
		# Update ingredient amount and show highlight if value changed
		if ingredient_ui.set_amount(difference):
			ingredient_ui.show_highlight(0.2, 15)
		
		if difference == 0:
			ingredient_ui.set_complete()

func _on_seconds_timeout():
	# Update Time / Timer
	order_timer.value -= 1
	order_time.text = str(order_timer.value)
	
	# Stop timer if 0 is reached
	if order_timer.value == 0:
		seconds_timer.stop()
