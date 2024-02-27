@icon("res://Textures/Fertilizer.png")
class_name NommieFertilizeEvent
extends PlantEvent

@export var nommies : Array[NommieGrowingFruit]

var icon_texture_override : Array[Texture2D] = [preload("res://Textures/FertilizerBlueIcon.png"), preload("res://Textures/FertilizerOrangeIcon.png"), preload("res://Textures/FertilizerGreenIcon.png")]
var target_fertilizer_type : Fertilizer.Type

var _target_amount : int = 1
var _current_amount : int = 0

func initialize():
	# Pick random fertilizer
	var type_index : int = randi() % Fertilizer.Type.size()
	var type_name : String = Fertilizer.Type.keys()[type_index]
	target_fertilizer_type = Fertilizer.Type[type_name]
	
	# Override icon texture
	icon_texture = icon_texture_override[type_index]
	
	_target_amount = nommies.size()
	
	for nommie in nommies:
		nommie.enable_fertilize_event(self)

func fertilizer_added() -> void:
	_current_amount += 1
	
	if _current_amount >= _target_amount:
		event_completed.emit()
