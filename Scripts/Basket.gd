class_name Basket
extends Node3D

@onready var quest_ui = $"Quest Viewport/Quest Display"
@onready var quest_between_timer : Timer = $"Time Between Quests"

var content : Dictionary = {}
var quest : Quest
var fruit_instances : Dictionary = {}

func _on_trigger_body_entered(body):
	if body.is_in_group("Fruit"):
		# Get type of fruit
		var fruit : Fruit = body
		
		# Add fruit to content
		if content.has(fruit.type):
			content[fruit.type] = content[fruit.type] + 1
		else:
			content[fruit.type] = 1
		
		# Append current fruit to instances. Using dictionary for fast lookup
		fruit_instances[body] = null
		
		quest_ui.update_quest(content)

func _on_trigger_body_exited(body):
	if body.is_in_group("Fruit"):
		# Get type of fruit
		var fruit : Fruit = body
		
		# Remove current fruit from instances
		fruit_instances.erase(body)
		
		# Add fruit to content
		if content.has(fruit.type):
			var new_amount : int = content[fruit.type] - 1
			
			if new_amount > 0:
				content[fruit.type] = new_amount
			else:
				content.erase(fruit.type)
			
			quest_ui.update_quest(content)

func _on_first_quest_offset_timeout():
	start_quest()

func start_quest():
	# Get quest
	quest = QuestManager.get_instance().generate_quest()
	
	# Connect events
	quest.failed.connect(_start_between_quest_timer)
	quest.success.connect(_start_between_quest_timer)
	quest.completed.connect(_remove_fruits)
	
	# Setup quest ui
	quest_ui.setup_quest(quest, content)

func _remove_fruits():
	for fruit in fruit_instances.keys():
		fruit.queue_free()
	
	fruit_instances.clear()

func _start_between_quest_timer():
	# Delete quest
	quest = null
	
	# Start timer
	quest_between_timer.start()

func _on_quest_display_quest_handled():
	# Start timer between quest
	quest_between_timer.start()

func _on_time_between_quests_timeout():
	# Start new quest
	start_quest()

func _on_quest_submit_button_pressed(button):
	if quest and quest.is_running():
		quest.check_completion(content)
