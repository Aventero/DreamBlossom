@icon("res://Textures/Stage.png")
class_name Stage
extends Node3D

signal stage_completed

# This is a stage
@export var run_time : float
@export var animation_name : String
var current_event : PlantEvent

func start_event():
	current_event = get_children().pick_random()
	current_event.initialize()
	current_event.event_completed.connect(Callable(on_event_completed))

func on_event_completed():
	print("Event completed!")
	current_event.event_completed.disconnect(Callable(on_event_completed))
	current_event.cleanup()
	stage_completed.emit()
	
