@icon("res://Textures/Fertilizer.png")
class_name FertilizeEvent
extends PlantEvent

# Order in array is defined by Fertilizer Type Enum order
@export var icon_texture_override : Array[Texture2D]

@onready var digspot : DigSpot = $"../../.."

var target_fertilizer_type : Fertilizer.Type

func initialize():
	# Pick random fertilizer
	var type_index : int = randi() % Fertilizer.Type.size()
	var type_name : String = Fertilizer.Type.keys()[type_index]
	target_fertilizer_type = Fertilizer.Type[type_name]
	
	# Override icon texture
	icon_texture = icon_texture_override[type_index]
	
	# Connect to fertilizer signal from digspot
	digspot.fertilizer_added.connect(Callable(_on_fertilizer_added))

func _on_fertilizer_added(type : Fertilizer.Type):
	if type == target_fertilizer_type:
		event_completed.emit()
	
	# TODO - Add consequence for wrong fertilizer

func cleanup():
	digspot.fertilizer_added.disconnect(Callable(_on_fertilizer_added))
