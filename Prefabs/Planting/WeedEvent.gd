@icon("res://Textures/WeedEvent.png")
class_name WeedEvent
extends PlantEvent

@export var event_weed : PackedScene
var _max_pulled : int = 0
var _pulled : int = 0
signal pulled_weed

func initialize():
	print("initialize Weed Event!")
	_max_pulled = get_child_count()
	pulled_weed.connect(Callable(_on_pulled_weed))
	
	# for each spawnpoint spawn weed
	for child in get_children():
		var added_weed = event_weed.instantiate()
		var initial_scale = added_weed.scale
		added_weed.scale = Vector3.ZERO
		child.add_child(added_weed)
		var tween : Tween = create_tween()
		tween.tween_property(added_weed, "scale", initial_scale, 1)
	
func _on_pulled_weed():
	_pulled += 1
	if _pulled >= _max_pulled:
		event_completed.emit()
	
