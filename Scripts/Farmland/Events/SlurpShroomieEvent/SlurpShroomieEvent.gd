@icon("res://Textures/EditorIcons/SlurpShroomieEvent.png")
class_name SlurpShroomieEvent
extends PlantEvent

@export var slurp_shroomie : PackedScene

var requested_potion_type: Potion.TYPE
var _slurp_shroomie_amount : int = 0
var _slurped_amount : int = 0


var icon_overrides : Dictionary[Potion.TYPE, Texture2D] = {
	Potion.TYPE.RED: preload("res://Textures/EventIcons/SlurpShroomieRed.png"),
	Potion.TYPE.GREEN: preload("res://Textures/EventIcons/SlurpShroomieGreen.png"),
	Potion.TYPE.BLUE: preload("res://Textures/EventIcons/SlurpShroomieBlue.png"),
}

func check_feasibility():
	if not GameBase.level:
		return
	
	# Brewing is on, dont delete it
	if GameBase.level.enable_brewing:
		return
	
	print("removing enable_brewing")
	# Delete self
	queue_free()


func initialize():
	_slurp_shroomie_amount = get_child_count()
	requested_potion_type = [Potion.TYPE.RED, Potion.TYPE.GREEN, Potion.TYPE.BLUE].pick_random()
	
	# For each spawnpoint spawn a bad shroomie
	for child in get_children():
		var slurp_shroomie_instance : SlurpShroomie = slurp_shroomie.instantiate()
		child.add_child(slurp_shroomie_instance)
		slurp_shroomie_instance.load_materials()
		slurp_shroomie_instance.requested_potion_type = requested_potion_type
		slurp_shroomie_instance._particle_material.albedo_color = Potion.get_potion_data(requested_potion_type, Potion.PROPERTIES.COLOR)
		
		var initial_scale = slurp_shroomie_instance.scale
		slurp_shroomie_instance.rotation = Vector3.ZERO
		slurp_shroomie_instance.scale = Vector3(0.001, 0.001, 0.001)
		slurp_shroomie_instance.slurp_event = self
		
		var tween : Tween = create_tween()
		tween.tween_property(slurp_shroomie_instance, "scale", initial_scale, 0.5)
		
		await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
	
	icon_texture = icon_overrides[requested_potion_type]

func shroomie_slurped():
	_slurped_amount += 1
	
	if _slurped_amount >= _slurp_shroomie_amount:
		event_completed.emit()
