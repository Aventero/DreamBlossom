@icon("res://Textures/Stage.png")
class_name Stage
extends Node3D

signal stage_complete

@export var run_time : float
@export var animation_name : String

@onready var icon_display : IconDisplay = $"../IconDisplay"

var current_event : PlantEvent

func start_events():
	# Pick random event
	current_event = get_children().pick_random()
	
	# Initalize event
	current_event.initialize()
	current_event.event_completed.connect(Callable(_on_event_completed))
	icon_display.show_icon(current_event.icon_texture)

func _on_event_completed():
	print("Event ", current_event.name, " completed!")
	
	# Events cleanup
	current_event.event_completed.disconnect(Callable(_on_event_completed))
	current_event.cleanup()
	icon_display.hide_icon()
	
	# TODO - Check if stage is completed
	stage_complete.emit()
