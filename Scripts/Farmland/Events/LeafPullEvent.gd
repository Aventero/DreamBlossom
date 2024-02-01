@icon("res://Textures/LeafPullEvent.png")
class_name LeafPullEvent
extends PlantEvent

@export var leaf_pull_point : PackedScene
@export var max_pull_count : int
var pull_count = 0
signal pulled_leaf

func initialize():
	
	# safety net
	if max_pull_count > get_child_count():
		max_pull_count = get_child_count()
	
	# pick random children until the max is reached
	var picked_children : Array
	var i = 0
	while i < max_pull_count:
		var child = get_children().pick_random()
		if not picked_children.has(child):
			picked_children.append(child)
			i += 1
	
	# instantiate the leafs
	for child in picked_children:
		var added_pull_point = leaf_pull_point.instantiate()
		added_pull_point.scale = Vector3.ZERO
		var tween : Tween = create_tween()
		tween.tween_property(added_pull_point, "scale", Vector3.ONE, 1)
		child.add_child(added_pull_point)
	
	pulled_leaf.connect(Callable(_increase_pull_count))
	
func _increase_pull_count():
	pull_count += 1
	print("_increase_pull_count: ", pull_count)
	if pull_count >= max_pull_count:
		event_completed.emit()

func cleanup():
	pass
