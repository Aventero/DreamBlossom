class_name Fruit
extends Ingredient

var fruit_event : FruitEvent

var _first_pickup : bool = true

func _on_picked_up(picked_fruit : Fruit):
	if _first_pickup:
		_first_pickup = false
		reparent(get_tree().current_scene)
		
		if is_instance_valid(fruit_event):
			fruit_event.first_fruit_pickup(picked_fruit)
