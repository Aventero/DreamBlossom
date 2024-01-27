@icon("res://Textures/Quest.png")
class_name QuestManager
extends Node3D

var active_quests : Array[Quest]

static var instance : QuestManager

func _ready():
	# Setup Singelton
	if instance == null:
		instance = self
	else:
		queue_free()

static func get_instance() -> QuestManager:
	return instance

func generate_quest() -> Quest:
	# Generate new quest - DEBUG # 
	var quest : Quest = Quest.new()
	quest.quest_name = "Debug Quest"
	quest.time = 10
	quest.add_requirement(Fruit.Type.ORANGIE, 3)
	# DEBUG END #
	
	# Setup quest object
	quest.name = quest.quest_name
	
	# Add quest
	add_child(quest)
	active_quests.append(quest)
	
	#quest.start(quest.time)
	
	return quest
