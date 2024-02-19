@icon("res://Textures/WaterDrop.png")
class_name ShellieWateringEvent
extends PlantEvent

@export var impacted_corals : Array[ShellieWatering]
@export var watering_amount : int = 5

var outline_material = preload("res://Materials/Outline.tres")

var _corals_watered : int = 0

func initialize():
	# Shrink corals
	for coral in impacted_corals:
		coral.setup(coral.get_parent_node_3d(), self)

func coral_watered():
	_corals_watered += 1
	
	if _corals_watered >= impacted_corals.size():
		event_completed.emit()
