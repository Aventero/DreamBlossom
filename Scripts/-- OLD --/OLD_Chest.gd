class_name Chest
extends Node3D

@onready var quest_ui = $"Quest Viewport/Quest Display"
@onready var quest_between_timer : Timer = $"Time Between Quests"
@onready var chest_lid : Node3D = $Model/Anchor

@export var jiggle_strength : float = 0.1

var content : Dictionary = {}
var ingredient_instances : Dictionary = {}

func _on_trigger_body_entered(body):
	if body.is_in_group("Ingredient"):
		# Get type of fruit
		var ingredient : Ingredient = body
		
		# Add fruit to content
		if content.has(ingredient.type):
			content[ingredient.type] = content[ingredient.type] + 1
		else:
			content[ingredient.type] = 1
		
		# Append current fruit to instances. Using dictionary for fast lookup
		ingredient_instances[body] = null
		
		quest_ui.update_quest(content)

func _on_trigger_body_exited(body):
	if body.is_in_group("Ingredient"):
		# Get type of fruit
		var ingredient : Ingredient = body
		
		# Remove current fruit from instances
		ingredient_instances.erase(body)
		
		# Add fruit to content
		if content.has(ingredient.type):
			var new_amount : int = content[ingredient.type] - 1
			
			if new_amount > 0:
				content[ingredient.type] = new_amount
			else:
				content.erase(ingredient.type)
			
			quest_ui.update_quest(content)

func _on_first_quest_offset_timeout():
	start_quest()

func start_quest():
	# Get quest
	if not LevelManager.get_instance().new_quest():
		return
	
	# Open chest lid
	var tween : Tween = create_tween()
	tween.tween_property(chest_lid, "rotation", Vector3(-2.44, 0, 0), 0.5)
	
	# Connect events
	#LevelManager.quest.completed.connect(_handle_quest_completion)
	#LevelManager.quest.request_completion_check.connect(LevelManager.quest.check_completion.bind(content))
	
	# Setup quest ui
	quest_ui.setup_quest(content)

func _handle_quest_completion(success : bool):
	# Close lid
	var tween : Tween = create_tween()
	tween.tween_property(chest_lid, "rotation", Vector3(0, 0, 0), 0.5)
	tween.tween_callback(_remove_fruits)
	
	# Jiggle
	await tween.finished
	await _chest_jiggle().finished
	
	# Wait after jiggle for better feeling
	await get_tree().create_timer(1.0).timeout
	
	if success:
		# TODO - Teleporation VFX
		# TODO - "You did it" Feedback
		pass
	else:
		await _chest_shake().finished
		# TODO - Make Appa angrier
	
	# Start timer for next quest
	quest_between_timer.start()

func _chest_jiggle():
	var tween : Tween = create_tween()
	tween.set_loops(4)
	tween.tween_property($Model, "scale", Vector3(1.0, 1.0 + jiggle_strength, 1.0), 0.2)
	tween.tween_property($Model, "scale", Vector3(1.0 + jiggle_strength, 1.0 - jiggle_strength, 1.0 + jiggle_strength), 0.2)
	
	return tween

func _chest_shake():
	var tween : Tween = create_tween()
	tween.set_loops(2)
	tween.tween_property($Model, "rotation", Vector3(0, 0.1570796, 0), 0.05)
	tween.tween_property($Model, "rotation", Vector3(0, 0, 0), 0.05)
	tween.tween_property($Model, "rotation", Vector3(0, -0.1570796, 0), 0.05)
	tween.tween_property($Model, "rotation", Vector3(0, 0, 0), 0.05)
	
	# Spawn failed particles
	$Failed.emitting = true
	
	return tween

func _remove_fruits():
	for ingredient in ingredient_instances.keys():
		ingredient.queue_free()
	
	ingredient_instances.clear()

func _on_time_between_quests_timeout():
	# Start new quest
	start_quest()

func _on_quest_submit_button_pressed(button):
	#if LevelManager.quest:
		#LevelManager.quest.check_completion(content)
	pass
