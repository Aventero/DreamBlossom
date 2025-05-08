@icon("res://Textures/EditorIcons/SlurpShroomieEvent.png")
class_name SlurpShroomieEvent
extends PlantEvent

@export var slurp_shroomie : PackedScene

var _slurp_shroomie_amount : int = 0
var _slurped_amount : int = 0

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
	
	# For each spawnpoint spawn a bad shroomie
	for child in get_children():
		var slurp_shroomie_instance : Node3D = slurp_shroomie.instantiate()
		child.add_child(slurp_shroomie_instance)
		
		var initial_scale = slurp_shroomie_instance.scale
		slurp_shroomie_instance.rotation = Vector3.ZERO
		slurp_shroomie_instance.scale = Vector3(0.001, 0.001, 0.001)
		slurp_shroomie_instance.slurp_event = self
		
		var tween : Tween = create_tween()
		tween.tween_property(slurp_shroomie_instance, "scale", initial_scale, 0.5)
		
		await get_tree().create_timer(randf_range(0.1, 0.5)).timeout

func shroomie_slurped():
	_slurped_amount += 1
	
	if _slurped_amount >= _slurp_shroomie_amount:
		event_completed.emit()
