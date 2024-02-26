class_name NommieFruit
extends Fruit

@onready var upper_head : Node3D = $Model/Upper_Head
@onready var lower_head : Node3D = $Model/Lower_Head

var _movement_tween : Tween

func _on_action_pressed(pickable):
	if _movement_tween and _movement_tween.is_running():
		_movement_tween.kill()
	
	_movement_tween = create_tween().set_parallel(true)
	_movement_tween.tween_property(upper_head, "rotation", Vector3(-0.79237948, 0, 0), 0.1)
	_movement_tween.tween_property(lower_head, "rotation", Vector3.ZERO, 0.1)

func _on_action_released(pickable):
	if _movement_tween and _movement_tween.is_running():
		_movement_tween.kill()
	
	_movement_tween = create_tween().set_parallel(true)
	_movement_tween.tween_property(upper_head, "rotation", Vector3(-0.886627, 0, 0), 0.1)
	_movement_tween.tween_property(lower_head, "rotation", Vector3(0.122173, 0, 0), 0.1)
