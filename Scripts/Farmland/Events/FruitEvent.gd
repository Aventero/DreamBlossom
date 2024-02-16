@icon("res://Textures/FruitEvent.png")
class_name FruitEvent
extends PlantEvent

@export var fruit : PackedScene

@export_category("Spawn Settings")
@export var delayed_spawn : bool = true
@export var scale_by_spawn : bool = true
@export var start_scale : Vector3 = Vector3.ZERO
@export var scale_length : float = 1.0
@export var despawn_models : Array[Node3D]

var _max_picked : int = 0
var _picked : int = 0

func initialize():
	_max_picked = get_child_count()
	
	# Despawn old models
	for fruit in despawn_models:
		var tween : Tween = create_tween()
		tween.tween_property(fruit, "scale", Vector3(1.1, 1.1, 1.1), scale_length)
		tween.tween_callback(func(): fruit.visible = false)
		tween.tween_callback(fruit.queue_free)
	
	# for each spawnpoint spawn a fruit
	for child in get_children():
		var added_fruit = fruit.instantiate()
		child.add_child(added_fruit)
		
		added_fruit.rotation = Vector3.ZERO
		added_fruit.fruit_event = self
		
		if scale_by_spawn:
			added_fruit.visible = false
			
			var initial_scale = added_fruit.scale
			added_fruit.scale = start_scale
			
			var tween : Tween = create_tween()
			tween.tween_interval(scale_length)
			tween.tween_callback(func(): added_fruit.visible = true)
			tween.tween_property(added_fruit, "scale", initial_scale, scale_length)
		
		if delayed_spawn:
			await get_tree().create_timer(randf_range(0.1, 2.0)).timeout

# check when a fruit is picked
func first_fruit_pickup(picked_fruit : Fruit):
	_picked += 1
	
	if _picked >= _max_picked:
		event_completed.emit()
