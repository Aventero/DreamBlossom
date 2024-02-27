@icon("res://Textures/EditorIcons/Cog.png")
class_name LevelManager
extends Node3D

@export var debug_level : int = 1

static var instance : LevelManager
static var level : Level
static var order : Order

func _ready():
	# Setup Singelton
	if instance == null:
		instance = self
	else:
		queue_free()
	
	# Load level
	_load_level(debug_level)
	
	# DEBUG
	level.completed.connect(func(): print("Level completed!"))

static func get_instance() -> LevelManager:
	return instance

func _load_level(level : int):
	self.level = load("res://Levels/Level" + str(level) + ".tscn").instantiate()
	add_child(self.level)

func next_order() -> bool:
	# Get current quest from level
	var new_order = level.get_order()
	
	# Break if there are no quests left
	if not new_order:
		return false
	
	if new_order != order:
		order = new_order
		order.completed.connect(_on_order_completed)
	
	return true

func _on_order_completed(success : bool):
	order.queue_free()
	order = null
