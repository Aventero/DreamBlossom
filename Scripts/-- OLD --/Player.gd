extends Node

# Hunger
@export var max_hunger : float = 100
@export var hunger : float = 100
@export var hunger_decrease_per_tick : float = 0.01

func _ready():
	hunger = max_hunger


func _process(delta):
	# Handle hunger
	_handle_hunger()


# Handle hunger decrease at each tick
func _handle_hunger():
	hunger -= hunger_decrease_per_tick


# Restore food by amount
func restore_food(amount : float):
	hunger = clamp(hunger + amount, 0, max_hunger)
