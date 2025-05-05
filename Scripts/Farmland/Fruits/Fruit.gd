@tool
class_name Fruit
extends Ingredient

var outline_mesh : Node3D
var fruit_event : FruitEvent
var _first_pickup : bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return;
	super()
	outline_mesh = $Model/Outline
	
func _on_picked_up(picked_fruit : Fruit):
	if _first_pickup:
		_first_pickup = false
		reparent(get_tree().current_scene)
		
		outline_mesh.visible = false
		
		if is_instance_valid(fruit_event):
			fruit_event.first_fruit_pickup(picked_fruit)
		
		await get_tree().create_timer(0.1).timeout.connect(deferred_return_add.bind(self))

func deferred_return_add(returnable) -> void:
	var game_base: GameBase = get_node("/root/Staging/Scene/World")
	game_base.return_manager.add_returnable(returnable)

# Override with custom class / function
func _on_action_pressed(_pickable):
	pass

# Override with custom class / function
func _on_action_released(_pickable):
	pass

func _on_dropped(pickable):
	# Make sure to remove trigger animation if applied
	_on_action_released(pickable)
