@icon("res://Textures/Cog.png")
class_name LevelManager
extends Node3D

@export var debug_level : int = 1

static var instance : LevelManager
static var level : Level
static var quest : Quest

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

func new_quest() -> bool:
	# Get current quest from level
	var new_quest = level.get_quest()
	
	# Break if there are no quests left
	if not new_quest:
		return false
	
	if new_quest != quest:
		quest = new_quest
		quest.completed.connect(_on_quest_completed)
	
	return true

func _on_quest_completed(success : bool):
	quest.queue_free()
	quest = null
