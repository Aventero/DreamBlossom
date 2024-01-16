@icon("res://Textures/PruneEvent.png")
class_name PruneEvent
extends PlantEvent

@export var dead_leaf : PackedScene

func initialize():
	for child in get_children():
		var instantiaded_leaf = dead_leaf.instantiate()
		instantiaded_leaf.scale = Vector3.ZERO
		var tween : Tween = create_tween()
		tween.tween_property(instantiaded_leaf, "scale", Vector3.ONE, 1)
		child.add_child(instantiaded_leaf)

# collect the pruned leafs (pruneable)
