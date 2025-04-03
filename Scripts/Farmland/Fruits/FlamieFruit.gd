@tool
class_name FlamieFruit
extends Fruit

@onready var model : Node3D = $Model

var _squish_tween : Tween

func _on_action_pressed(_pickable):
	if _squish_tween and _squish_tween.is_running():
		_squish_tween.kill()
	
	_squish_tween = create_tween()
	_squish_tween.tween_property(model, "scale", Vector3(1.1, 0.9, 1.1), 0.1)

func _on_action_released(_pickable):
	if _squish_tween and _squish_tween.is_running():
		_squish_tween.kill()
	
	_squish_tween = create_tween()
	_squish_tween.tween_property(model, "scale", Vector3.ONE, 0.1)
