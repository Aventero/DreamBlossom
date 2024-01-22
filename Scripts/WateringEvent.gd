@icon("res://Textures/WaterDrop.png")
class_name WateringEvent
extends PlantEvent

@onready var digspot : DigSpot = $"../../.."
@export var water_needed : int = 5

func initialize():
	# Reset watering state on digspot
	digspot.reset_watering(water_needed)
	
	digspot.watering_completed.connect(Callable(_increase_water_level))

func cleanup():
	digspot.watering_completed.disconnect(Callable(_increase_water_level))

func _increase_water_level():
	event_completed.emit()
