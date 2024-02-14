@icon("res://Textures/FruitEvent.png")
class_name FruitEvent
extends PlantEvent

@export var fruit : PackedScene
var _max_picked : int = 0
var _picked : int = 0

func initialize():
	print("[FruitEvent] Initialize")
	_max_picked = get_child_count()
	
	# for each spawnpoint spawn a fruit
	for child in get_children():
		var added_fruit = fruit.instantiate()
		child.add_child(added_fruit)
		
		var initial_scale = added_fruit.scale
		added_fruit.rotation = Vector3.ZERO
		added_fruit.scale = Vector3.ZERO
		added_fruit.fruit_event = self
		
		var tween : Tween = create_tween()
		tween.tween_property(added_fruit, "scale", initial_scale, 1)
		
		await get_tree().create_timer(randf_range(0.1, 2.0)).timeout

# check when a fruit is picked
func first_fruit_pickup(picked_fruit : Fruit):
	_picked += 1
	print("[FruitEvent] Picked_fruit count: ", _picked)
	
	if _picked >= _max_picked:
		event_completed.emit()
