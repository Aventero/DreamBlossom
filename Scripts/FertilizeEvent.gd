@icon("res://Textures/Fertilizer.png")
class_name FertilizeEvent
extends PlantEvent

@onready var digspot : DigSpot = $"../../.."

var target_fertilizer_type : Fertilizer.Type

func initialize():
	# Pick random fertilizer
	var type_name : String = Fertilizer.Type.keys()[randi() % Fertilizer.Type.size()]
	target_fertilizer_type = Fertilizer.Type[type_name]
	
	# Connect to fertilizer signal from digspot
	digspot.fertilizer_added.connect(Callable(_on_fertilizer_added))

func _on_fertilizer_added(type : Fertilizer.Type):
	if type == target_fertilizer_type:
		event_completed.emit()
	
	# TODO - Add consequence for wrong fertilizer

func cleanup():
	digspot.fertilizer_added.disconnect(Callable(_on_fertilizer_added))
