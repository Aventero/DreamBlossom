class_name Fruit
extends Ingredient

@onready var outline_mesh : MeshInstance3D = $Model/Outline

var fruit_event : FruitEvent

var _first_pickup : bool = true

func _on_picked_up(picked_fruit : Fruit):
	if _first_pickup:
		_first_pickup = false
		reparent(get_tree().current_scene)
		
		outline_mesh.visible = false
		
		if is_instance_valid(fruit_event):
			fruit_event.first_fruit_pickup(picked_fruit)

func _on_xr_tools_highlight_visible_visibility_change(visible):
	if not _first_pickup:
		return
	
	outline_mesh.visible = !visible
