@icon("res://Textures/EditorIcons/Stage.png")
class_name Stage
extends Node3D

signal stage_complete

@export var animation_time : float
@export var animation_name : String
@export var icon_position : Vector3
@export var should_play_animation = true

@onready var icon_display : IconDisplay = $"../IconDisplay"
var current_event : PlantEvent

func check_feasibility() -> void:
	for event: PlantEvent in get_children():
		event.check_feasibility()

# Started once the timer runs out
func start_events():
	# Pick random event
	current_event = get_children().pick_random()

	# Initalize event
	current_event.event_completed.connect(Callable(_on_event_completed))
	current_event.initialize()
	
	if current_event.icon_texture:
		icon_display.show_icon(current_event.icon_texture, icon_position)

func _on_event_completed():
	# Events cleanup
	current_event.event_completed.disconnect(Callable(_on_event_completed))
	current_event.cleanup()
	icon_display.hide_icon()
	
	stage_complete.emit()
