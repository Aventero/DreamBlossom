@icon("res://Textures/WaterDrop.png")
class_name WateringEvent
extends PlantEvent

@export var water_needed : int = 5

var digspot : DigSpot

func initialize():
	# Get digspot
	digspot = DigSpotLookup.get_dig_spot(self.owner)
	
	# Reset watering state on digspot
	digspot.reset_watering(water_needed)
	
	digspot.watering_completed.connect(Callable(_increase_water_level))

func cleanup():
	digspot.watering_completed.disconnect(Callable(_increase_water_level))

func _increase_water_level():
	event_completed.emit()
