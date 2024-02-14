@icon("res://Textures/WeedEvent.png")
class_name WeedEvent
extends PlantEvent

@export var event_weed : PackedScene

var _max_pulled : int = 0
var _pulled : int = 0

func initialize():
	_max_pulled = get_child_count()
	
	# for each spawnpoint spawn weed
	for child in get_children():
		var event_weed_instance = event_weed.instantiate()
		child.add_child(event_weed_instance)
		
		var initial_scale = event_weed_instance.scale
		event_weed_instance.scale = Vector3.ZERO
		event_weed_instance.weed_event = self
		
		var tween : Tween = create_tween()
		tween.tween_property(event_weed_instance, "scale", initial_scale, 0.5)
		
		await get_tree().create_timer(randf_range(0.1, 1.0)).timeout

func pulled_weed():
	_pulled += 1
	
	if _pulled >= _max_pulled:
		event_completed.emit()
