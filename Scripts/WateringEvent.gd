@icon("res://Textures/WaterDrop.png")
class_name WateringEvent
extends PlantEvent

@onready var digspot : DigSpot = $"../../.."
@export var water_needed : int = 5
var current_water_level : int

func initialize():
	# look at dig spot if watering complete
	digspot.water_added.connect(Callable(_increase_water_level))
	
func cleanup():
	digspot.water_added.disconnect(Callable(_increase_water_level))

func _increase_water_level():
	current_water_level += 1
	if current_water_level >= water_needed:
		event_completed.emit()
