@icon("res://Textures/LeafPullEvent.png")
class_name KnospEvent
extends PlantEvent

@export var knosp : PackedScene
@export var max_knosp_amount : int

var _opened_count = 0

func initialize():
	# safety net
	if max_knosp_amount > get_child_count():
		max_knosp_amount = get_child_count()
	
	# pick random children until the max is reached
	var picked_children : Array
	var i = 0
	while i < max_knosp_amount:
		var child = get_children().pick_random()
		if not picked_children.has(child):
			picked_children.append(child)
			i += 1
	
	# instantiate the leafs
	for child in picked_children:
		var knosp_instance = knosp.instantiate()
		child.add_child(knosp_instance)
		
		knosp_instance.scale = Vector3.ZERO
		knosp_instance.knosp_event = self
		
		var tween : Tween = create_tween()
		tween.tween_property(knosp_instance, "scale", Vector3.ONE, 0.5)
		
		await get_tree().create_timer(randf_range(0.1, 0.5)).timeout

func knosp_open():
	_opened_count += 1
	
	if _opened_count >= max_knosp_amount:
		event_completed.emit()
