@icon("res://Textures/EditorIcons/WaterDrop.png")
class_name NommieWateringEvent
extends PlantEvent

@export var target_water_amount : int = 4
@export var nommies : Array[NommieGrowingFruit]

var _target_amount : int = 1
var _current_amount : int = 0

func initialize():
	_target_amount = nommies.size()
	
	# Enable event triggers
	for nommie in nommies:
		nommie.enable_watering_event(self)

func watering_completed():
	_current_amount += 1
	
	if _current_amount >= _target_amount:
		event_completed.emit()
