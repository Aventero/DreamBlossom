@icon("res://Textures/PruneEvent.png")
class_name PruneEvent
extends PlantEvent

@export var dead_leaf : PackedScene
@export var max_prune_count : int
var prune_count = 0
signal pruned_leaf

func initialize():
	
	# safety net
	if max_prune_count > get_child_count():
		max_prune_count = get_child_count()
	
	# pick random children until the max is reached
	var picked_children : Array
	var i = 0
	while i < max_prune_count:
		var child = get_children().pick_random()
		if not picked_children.has(child):
			picked_children.append(child)
			i += 1
	
	# instantiate the leafs
	for child in picked_children:
		var instantiaded_leaf = dead_leaf.instantiate()
		instantiaded_leaf.scale = Vector3.ZERO
		var tween : Tween = create_tween()
		tween.tween_property(instantiaded_leaf, "scale", Vector3.ONE, 1)
		child.add_child(instantiaded_leaf)
	
	pruned_leaf.connect(Callable(_increase_prune_count))
	
func _increase_prune_count():
	prune_count += 1
	print("_increase_prune_count: ", prune_count)
	if prune_count >= max_prune_count:
		event_completed.emit()

func cleanup():
	pass
