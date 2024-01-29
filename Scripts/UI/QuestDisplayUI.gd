class_name QuestDisplayUI
extends Control

signal quest_handled

@export var fruit_icons : Array[QuestIconData]
@export var failed_duration : float = 3.0
@export var fade_duration : float = 0.2

@onready var fruit_displays : Control = $Container/Fruits
@onready var quest_timer : Slider = $Container/Timer
@onready var quest_time : Label = $Container/Timer/Label

var fruit_ui : PackedScene = load("res://Prefabs/UI/FruitUI.tscn")

var icon_lookup : Dictionary
var fruit_ui_lookup : Dictionary
var _internal_timer : Timer

func _ready():
	# Setup icon lookup
	for fruit_icon in fruit_icons:
		icon_lookup[fruit_icon.type] = fruit_icon.icon

func setup_quest(content : Dictionary):
	# Setup Quest
	LevelManager.quest.completed.connect(_hide_quest_screen)
	
	# Setup Quest UI
	_setup_quest_ui()
	update_quest(content)
	
	# Fade in Screen
	_show_quest_screen()
	
	# Start quest
	_start_quest_timers()

func _setup_quest_ui():
	var quest : Quest = LevelManager.quest
	
	# Setup time / timer
	quest_timer.max_value = quest.time
	quest_timer.value = quest_timer.max_value
	quest_time.text = str(quest.time)
	
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
	
	# Actual Quest Timer
	LevelManager.quest.start_quest()

func update_quest(content : Dictionary):
	if not LevelManager.quest:
		return
	
	for fruit in LevelManager.quest.get_required_fruits():
		if content.has(fruit):
			fruit_ui_lookup[fruit].set_amount(content[fruit])
		else:
			fruit_ui_lookup[fruit].set_amount(0)

func clear_quest():
	# Clear all fruit displays
	for display in fruit_displays.get_children():
		display.queue_free()
	
	# Clear lookup table
	fruit_ui_lookup.clear()

func _show_quest_screen():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), fade_duration)

func _hide_quest_screen(success : bool):
	var tween = get_parent().create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), fade_duration)
	tween.tween_callback(clear_quest)

func _on_timer_timeout():
	# Update time
	quest_timer.value -= 1
	quest_time.text = str(int(quest_time.text) - 1)
	
	# Stop timer if 0 is reached
	if quest_timer.value == 0:
		quest_timer.get_child(0).stop()
