@icon("res://Textures/EditorIcons/Stage.png")
class_name Level
extends Node3D

## Emit when new order started
signal new_order(order : Order)

## Emit when level is completed
signal completed

# Implemented
@export_group("Plants")
## Defines which plants are active in current level
@export_flags("Shroomie", "Blubburu", "Flamie", "Shellie", "Pumkie", "Nommie") var active_plants

@export_group("Tools")
## Defines which tools are active in current level
@export_flags("Scissors", "MusicBox", "PickAxe") var active_tools

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

@export_group("Brewing Settings")
## Enable brewing
@export var enable_brewing : bool = false
## Defines how many drops a brewed potion contains
@export var drops_per_potion : int = 5

@export_group("Cooking Settings")
@export var enable_cooking : bool = false

@export_group("Order Settings")
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
	Scissors = 1,
	MusicBox = 2,
	PickAxe = 4,
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
		
		# Emit new order signal
		self.new_order.emit(current_order)
	
	return true

func _on_order_completed(success : bool) -> void:
	print("Order done")
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
		"Scissors":
			return active_tools & Tools.Scissors != 0
		"MusicBox":
			return active_tools & Tools.MusicBox != 0
		"PickAxe":
			return active_tools & Tools.PickAxe != 0
	
	return false
