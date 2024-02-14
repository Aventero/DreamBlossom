@icon("res://Textures/BadShroomieEvent.png")
class_name BadShroomieEvent
extends PlantEvent

@export var bad_shroomie : PackedScene

func initialize():
	# For each spawnpoint spawn a bad shroomie
	for child in get_children():
		var bad_shroomie_instance = bad_shroomie.instantiate()
		child.add_child(bad_shroomie_instance)
		
		var initial_scale = bad_shroomie_instance.scale
		bad_shroomie_instance.rotation = Vector3.ZERO
		bad_shroomie_instance.scale = Vector3.ZERO
		
		var tween : Tween = create_tween()
		tween.tween_property(bad_shroomie_instance, "scale", initial_scale, 0.5)
		
		await get_tree().create_timer(randf_range(0.1, 0.5)).timeout

func cleanup():
	pass
