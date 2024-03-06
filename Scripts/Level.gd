@icon("res://Textures/EditorIcons/Stage.png")
class_name Level
extends Node3D

signal completed

# Implemented
@export_group("Plants")
@export_flags("Shroomie", "Blubburu", "Flamie", "Shellie", "Pumkie", "Nommie") var active_plants

@export_group("Tools")
@export_flags("Fertilizer Blue", "Fertilizer Orange", "Fertilizer Green", "Scissors", "MusicBox") var active_tools

@export_group("Weed Settings")
@export_range(0.0, 1.0, 0.01) var inital_weed_chance : float = 0.0
@export_range(0.0, 1.0, 0.01) var additional_weed_chance : float = 0.0

@export_group("Soil Setup")

@export_group("Koriko Settings")

@export_group("Additional Settings")

# Not Implemented

@export_group("Not implemented yet")
@export var spread_time : float = 0.0
@export_range(0.0, 1.0, 0.01) var spread_chance : float = 0.0

@export var soil_setup : String = ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"

@export var time_before_first_spawn : float = 0.0
@export_range(0.0, 1.0, 0.01) var inital_spawn_chance : float = 0.0
@export_range(0.0, 1.0, 0.01) var stack_spawn_chance : float = 0.0
@export var time_until_death : float = 0.0

@export var enable_cooking_chest : bool = false
@export var time_between_orders : float = 0.0

enum Plants {
	SHROOMIE = 1,
	BLUBBURU = 2,
	FLAMIE = 4,
	SHELLIE = 8,
	PUMKIE = 16,
	NOMMIE = 32
}

enum Tools {
	Fertilizer_Blue = 1,
	Fertilizer_Orange = 2,
	Fertilizer_Green = 4,
	Scissors = 8,
	MusicBox = 16
}

var current_order : Order = null

# Get most current quest from this level
func next_order() -> bool:
	# Get current quest from level
	if get_child_count() <= 0:
		return false
	
	var new_order : Order = get_child(0)
	
	if new_order != current_order:
		current_order = new_order
		current_order.completed.connect(_on_order_completed)
	
	return true

func _on_order_completed(success : bool) -> void:
	current_order.queue_free()
	current_order = null
	
	# Check if level is completed (No more orders)
	if get_child_count() == 0:
		completed.emit()
