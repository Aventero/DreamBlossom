@icon("res://Textures/EditorIcons/WaterDrop.png")
class_name WateringEvent
extends PlantEvent

@export var water_needed : int = 5

var digspot : DigSpot

func initialize():
	# Get digspot
	digspot = DigSpotLookup.get_dig_spot(self.owner)
	
	digspot.set_outline(true)
	
	# Reset watering state on digspot
	digspot.reset_watering(water_needed)
	
	digspot.watering_completed.connect(Callable(_watering_complete))

func cleanup():
	digspot.watering_completed.disconnect(Callable(_watering_complete))

func _watering_complete():
	digspot.set_outline(false)
	
	event_completed.emit()
