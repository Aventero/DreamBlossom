@icon("res://Textures/Fertilizer.png")
class_name FertilizeEvent
extends PlantEvent

var icon_texture_override : Array[Texture2D] = [preload("res://Textures/FertilizerBlueIcon.png"), preload("res://Textures/FertilizerOrangeIcon.png"), preload("res://Textures/FertilizerGreenIcon.png")]
var target_fertilizer_type : Fertilizer.Type
var digspot : DigSpot

func initialize():
	# Get digspot
	digspot = DigSpotLookup.get_dig_spot(self.owner)
	
	digspot.set_outline(true)
	
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
		digspot.set_outline(false)
		
		event_completed.emit()

func cleanup():
	digspot.fertilizer_added.disconnect(Callable(_on_fertilizer_added))
