@icon("res://Textures/EditorIcons/BadShroomieEvent.png")
class_name BadShroomieEvent
extends PlantEvent

@export var bad_shroomie : PackedScene

var _bad_shroomie_amount : int = 0
var _removed_amount : int = 0

func initialize():
	_bad_shroomie_amount = get_child_count()
	spawn_shroomie()

func spawn_shroomie() -> void:
	var spawn_point = get_children().get(_removed_amount)
	var bad_shroomie_instance : BadShroomie = bad_shroomie.instantiate()
	spawn_point.add_child(bad_shroomie_instance)
	
	var initial_scale = bad_shroomie_instance.scale
	bad_shroomie_instance.rotation = Vector3.ZERO
	bad_shroomie_instance.scale = Vector3(0.001, 0.001, 0.001)
	bad_shroomie_instance.bad_shroomie_event = self
	
	var tween : Tween = create_tween()
	tween.tween_property(bad_shroomie_instance, "scale", initial_scale, 0.5)
	icon_texture = load("res://Textures/EventIcons/ShroomiePull.png")

func shroomie_removed():
	_removed_amount += 1
	
	if _removed_amount >= _bad_shroomie_amount:
		event_completed.emit()
	else:
		spawn_shroomie()
