class_name Statistics
extends Node

# Current game data
static var elapsed_time : float = 0.0
static var failed_orders : int = 0
static var grown_plants : int = 0

func _ready() -> void:
	# Reset statistics on game start
	elapsed_time = 0.0
	failed_orders = 0
	grown_plants = 0

func _process(delta: float) -> void:
	elapsed_time += delta
