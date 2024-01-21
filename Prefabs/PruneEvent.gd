@icon("res://Textures/PruneEvent.png")
class_name PruneEvent
extends PlantEvent

@export var dead_leaf : PackedScene
var prune_count = 0
var prune_count_max = 0
signal pruned_leaf

func initialize():
	for child in get_children():
		var instantiaded_leaf = dead_leaf.instantiate()
		instantiaded_leaf.scale = Vector3.ZERO
		var tween : Tween = create_tween()
		tween.tween_property(instantiaded_leaf, "scale", Vector3.ONE, 1)
		child.add_child(instantiaded_leaf)
		prune_count_max += 1 # for each spawnpoint
	pruned_leaf.connect(Callable(_increase_prune_count))
	
func _increase_prune_count():
	prune_count += 1
	print("_increase_prune_count: ", prune_count)
	if prune_count >= prune_count_max:
		event_completed.emit()

func cleanup():
	pass
