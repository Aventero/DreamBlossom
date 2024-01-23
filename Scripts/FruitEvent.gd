@icon("res://Textures/FruitEvent.png")
class_name FruitEvent
extends PlantEvent

@export var fruit : PackedScene
var _max_picked : int = 0
var _picked : int = 0

func initialize():
	print("initialize Fruit Event!")
	_max_picked = get_child_count()
	
	# for each spawnpoint spawn a fruit
	for child in get_children():
		var added_fruit = fruit.instantiate()
		var initial_scale = added_fruit.scale
		added_fruit.scale = Vector3.ZERO
		child.add_child(added_fruit)
		var tween : Tween = create_tween()
		tween.tween_property(added_fruit, "scale", initial_scale, 1)

# check when a fruit is picked
func first_fruit_pickup(picked_fruit : Fruit):
	_picked += 1
	print("picked_fruit count: ", _picked)
	if _picked >= _max_picked:
		event_completed.emit()

func _process(delta):
	pass
