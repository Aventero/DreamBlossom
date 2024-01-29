@icon("res://Textures/Quest.png")
class_name QuestManager
extends Node3D

static var instance : QuestManager
static var quest : Quest

func _ready():
	# Setup Singelton
	if instance == null:
		instance = self
	else:
		queue_free()

static func get_instance() -> QuestManager:
	return instance

func generate_quest() -> void:
	# Generate new quest - DEBUG # 
	quest = Quest.new()
	quest.quest_name = "Debug Quest"
	quest.time = 10
	quest.add_requirement(Fruit.Type.ORANGIE, 3)
	# DEBUG END #
	
	# Setup quest object
	quest.name = quest.quest_name
	
	quest.completed.connect(_on_quest_completed)
	
	# Add quest
	add_child(quest)

func _on_quest_completed(success : bool):
	quest.queue_free()
	quest = null
