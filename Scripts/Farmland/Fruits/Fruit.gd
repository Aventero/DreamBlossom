@tool
class_name Fruit
extends Ingredient

var outline_mesh : Node3D
var fruit_event : FruitEvent
var _first_pickup : bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return;
		
	outline_mesh = $Model/Outline
	
func _on_picked_up(picked_fruit : Fruit):
	if _first_pickup:
		_first_pickup = false
		reparent(get_tree().current_scene)
		
		outline_mesh.visible = false
		
		if is_instance_valid(fruit_event):
			fruit_event.first_fruit_pickup(picked_fruit)

#func _on_xr_tools_highlight_visible_visibility_change(_visible):
	#if not _first_pickup:
		#return
	#
	#outline_mesh.visible = !_visible

# Override with custom class / function
func _on_action_pressed(_pickable):
	pass

# Override with custom class / function
func _on_action_released(_pickable):
	pass

func _on_dropped(pickable):
	# Make sure to remove trigger animation if applied
	_on_action_released(pickable)
