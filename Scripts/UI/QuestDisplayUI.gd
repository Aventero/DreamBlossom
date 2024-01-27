class_name QuestDisplayUI
extends Control

signal quest_handled

@export var fruit_icons : Array[QuestIconData]
@export var failed_duration : float = 3.0
@export var fade_duration : float = 0.2

@onready var fruit_displays : Control = $Background/MarginContainer/VBoxContainer/Fruits
@onready var quest_timer : Slider = $Background/MarginContainer/VBoxContainer/HBoxContainer/Timer
@onready var quest_time : Label = $Background/MarginContainer/VBoxContainer/HBoxContainer/Time

@onready var new_recipe_screen : Control = $"New Recipe"
@onready var quest_screen : Control = $Background/MarginContainer
@onready var failed_screen : Control = $"Failed Screen"
@onready var completed_screen : Control = $"Completed Screen"

var fruit_ui : PackedScene = load("res://Prefabs/UI/FruitUI.tscn")

var quest : Quest
var icon_lookup : Dictionary
var fruit_ui_lookup : Dictionary

var _internal_timer : Timer

func _ready():
	# Setup icon lookup
	for fruit_icon in fruit_icons:
		icon_lookup[fruit_icon.type] = fruit_icon.icon

func setup_quest(quest : Quest, content : Dictionary):
	# Setup quest
	self.quest = quest
	_setup_quest_ui()
	
	# Show new recipe screen
	var tween = get_parent().create_tween()
	
	# Fade in "New Recipe"
	tween.tween_property(new_recipe_screen, "modulate", Color(1.0, 1.0, 1.0, 1.0), fade_duration)
	tween.tween_interval(failed_duration)
	
	# Spawn in quest ui
	tween.tween_callback(func(): quest_screen.visible = true)
	
	# Update quest ui with current content
	tween.tween_callback(update_quest.bind(content))
	
	# Hide "New Recipe"
	tween.tween_property(new_recipe_screen, "modulate", Color(1.0, 1.0, 1.0, 0.0), fade_duration)
	
	# Start quest timers
	tween.tween_callback(_start_quest_timers)

func _setup_quest_ui():
	# Setup time / timer
	quest_timer.max_value = quest.time
	quest_timer.value = quest_timer.max_value
	quest_time.text = str(quest.time)
	
	quest.success.connect(show_completed_screen)
	quest.failed.connect(show_failed_screen)
	
	for fruit in quest.get_required_fruits():
		# Spawn new fruit ui
		var fruit_ui_instance = fruit_ui.instantiate()
		fruit_displays.add_child(fruit_ui_instance)
		
		# Set data
		fruit_ui_instance.set_icon(icon_lookup[fruit])
		fruit_ui_instance.set_target(quest.get_fruit_amount(fruit))
		fruit_ui_instance.set_amount(0)
		
		# Save instance in lookup table
		fruit_ui_lookup[fruit] = fruit_ui_instance

func _start_quest_timers():
	# UI Time Slider
	quest_timer.get_child(0).start()
	quest.start_quest()

func update_quest(content : Dictionary):
	if not quest:
		return
	
	for fruit in quest.get_required_fruits():
		if content.has(fruit):
			fruit_ui_lookup[fruit].set_amount(content[fruit])
		else:
			fruit_ui_lookup[fruit].set_amount(0)

func clear_quest():
	# Clear all fruit displays
	for display in fruit_displays.get_children():
		display.queue_free()
	
	# Hide quest screen
	quest_screen.visible = false
	
	# Clear lookup table
	fruit_ui_lookup.clear()
	quest = null

func show_completed_screen():
	var tween = get_parent().create_tween()
	tween.tween_property(completed_screen, "modulate", Color(1.0, 1.0, 1.0, 1.0), fade_duration)
	tween.tween_callback(clear_quest)
	tween.tween_interval(failed_duration)
	tween.tween_property(completed_screen, "modulate", Color(1.0, 1.0, 1.0, 0.0), fade_duration)
	tween.tween_callback(func(): quest_handled.emit())

func show_failed_screen():
	var tween = get_parent().create_tween()
	tween.tween_property(failed_screen, "modulate", Color(1.0, 1.0, 1.0, 1.0), fade_duration)
	tween.tween_callback(clear_quest)
	tween.tween_interval(failed_duration)
	tween.tween_property(failed_screen, "modulate", Color(1.0, 1.0, 1.0, 0.0), fade_duration)
	tween.tween_callback(func(): quest_handled.emit())

func _on_timer_timeout():
	# Update time
	quest_timer.value -= 1
	quest_time.text = str(int(quest_time.text) - 1)
	
	# Stop timer if 0 is reached
	if quest_timer.value == 0:
		quest_timer.get_child(0).stop()
