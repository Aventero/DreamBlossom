@icon("res://Textures/EditorIcons/PruneEvent.png")
class_name PruneEvent
extends PlantEvent

@export var dead_leaf : PackedScene
@export var max_prune_count : int

var _prune_count = 0

func check_feasibility():
	if not GameBase.level:
		return
	
	if GameBase.level.is_tool_active("Scissors"):
		return
	
	# Delete self
	queue_free()

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
		var leaf_instance = dead_leaf.instantiate()
		child.add_child(leaf_instance)
		
		var initial_scale = leaf_instance.scale
		leaf_instance.scale = Vector3.ZERO
		leaf_instance.prune_event = self
		
		var tween : Tween = create_tween()
		tween.tween_property(leaf_instance, "scale", initial_scale, 1)
		
		await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
	icon_texture = load("res://Textures/EventIcons/Prune.png")

func pruned_leaf():
	_prune_count += 1
	
	if _prune_count >= max_prune_count:
		event_completed.emit()
