class_name ShellieFruit
extends Fruit

@onready var top_shell : Node3D = $Model/TopShell
@onready var orb : Node3D = $Model/Orb
@onready var face : Node3D = $Model/Face

var _movement_tween : Tween

func _on_action_pressed(pickable):
	if _movement_tween and _movement_tween.is_running():
		_movement_tween.kill()
	
	_movement_tween = create_tween().set_parallel(true)
	
	# Shell
	_movement_tween.tween_property(top_shell, "rotation", Vector3(-0.09599311, 0.0, 0.0), 0.1)
	
	# Orb
	_movement_tween.tween_property(orb, "position", Vector3(0.0, 0.0, 0.021), 0.1)
	_movement_tween.tween_property(orb, "scale", Vector3(0.5, 0.5, 0.5), 0.1)
	
	# Face
	_movement_tween.tween_property(face, "scale", Vector3(0.5, 0.5, 0.5), 0.1)
	_movement_tween.tween_property(face, "position", Vector3(0.0, 0.0, 0.022), 0.1)

func _on_action_released(pickable):
	if _movement_tween and _movement_tween.is_running():
		_movement_tween.kill()
	
	_movement_tween = create_tween().set_parallel(true)
	
	# Shell
	_movement_tween.tween_property(top_shell, "rotation", Vector3(-0.5916666, 0.0, 0.0), 0.1)
	
	# Orb
	_movement_tween.tween_property(orb, "position", Vector3.ZERO, 0.1)
	_movement_tween.tween_property(orb, "scale", Vector3.ONE, 0.1)
	
	# Face
	_movement_tween.tween_property(face, "scale", Vector3.ONE, 0.1)
	_movement_tween.tween_property(face, "position", Vector3.ZERO, 0.1)
