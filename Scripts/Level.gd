@icon("res://Textures/EditorIcons/Stage.png")
class_name Level
extends Node3D

signal completed

# Implemented
@export_group("Plants")
## Defines which plants are active in current level
@export_flags("Shroomie", "Blubburu", "Flamie", "Shellie", "Pumkie", "Nommie") var active_plants

@export_group("Tools")
## Defines which tools are active in current level
@export_flags("Fertilizer Blue", "Fertilizer Orange", "Fertilizer Green", "Scissors", "MusicBox", "PickAxe") var active_tools

@export_group("Weed Settings")
## Time between spreads
@export var spread_time : float = 0.0
## Time before weed is spreading. Indicated with weed jiggle
@export var spread_indicator_time : float = 0.0
## Time between grab release and end of indicator time in which spreading is canceled
@export var spread_release_grace_time : float = 0.0
## Chance that a single weed is spreading
@export_range(0.0, 1.0, 0.01) var spread_chance : float = 0.0
## Spawn chance for obstacle (Weed, Rock, etc) to spawn per cell upon digspot removal
@export_range(0.0, 1.0, 0.01) var obstacle_spawn_chance : float = 0.0

@export_group("Soil Setup")
## Starting arrangement of soil
## Each cell is represented ('' = Empty, 'W' = Weed).
## Each cell is seperated by an ,
@export var soil_setup : String = ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"

@export_group("Koriko Settings")
## Time before koriko spawn timer is started
@export var time_before_first_spawn : float = 0.0
## Inital spawn chance for a koriko
@export_range(0.0, 1.0, 0.01) var inital_spawn_chance : float = 0.0
## Spawn chance gets increased by this value after spawning attempt fails
@export_range(0.0, 1.0, 0.01) var stack_spawn_chance : float = 0.0
## Time until koriko is killing you
@export var time_until_death : float = 0.0

@export_group("Additional Settings")
@export var enable_cooking_chest : bool = false
@export var time_between_orders : float = 0.0

# Not Implemented
@export_group("Not implemented yet")

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
	MusicBox = 16,
	PickAxe = 32,
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
	
	# Update current game statistics
	if not success:
		Statistics.failed_orders += 1
	
	# Check if level is completed (No more orders)
	if get_child_count() == 1:
		completed.emit()

func is_tool_active(tool : String) -> bool:
	match tool:
		"Fertilizer Blue":
			return active_tools & Tools.Fertilizer_Blue != 0
		"Fertilizer Orange":
			return active_tools & Tools.Fertilizer_Orange != 0
		"Fertilizer Green":
			return active_tools & Tools.Fertilizer_Green != 0
		"Scissors":
			return active_tools & Tools.Scissors != 0
		"MusicBox":
			return active_tools & Tools.MusicBox != 0
		"PickAxe":
			return active_tools & Tools.PickAxe != 0
	
	return false
