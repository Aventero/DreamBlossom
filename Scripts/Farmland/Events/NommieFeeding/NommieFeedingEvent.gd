class_name NommieFeedingEvent
extends PlantEvent

@export var nommies : Array[NommieGrowingFruit]

var _target_amount : int = 1
var _current_amount : int = 0

func initialize():
	_target_amount = nommies.size()
	
	# Enable event triggers
	for nommie in nommies:
		nommie.enable_feeding_event(self)
	icon_texture = load("res://Textures/EventIcons/NommieFeeding.png")

func feeding_complete():
	_current_amount += 1
	
	if _current_amount >= _target_amount:
		event_completed.emit()
