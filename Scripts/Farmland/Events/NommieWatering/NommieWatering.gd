@icon("res://Textures/EditorIcons/WaterDrop.png")
class_name NommieWatering
extends Area3D

var _event : NommieWateringEvent
var _current_watering_amount : int = 0

func setup(event : NommieWateringEvent) -> void:
	_event = event
	_current_watering_amount = 0
	
	# Open mouth
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property($"../Model/Lower_Head", "rotation", Vector3(0.296706, 0, 0), 0.5)
	tween.tween_property($"../Model/Upper_Head", "rotation", Vector3(-1.5, 0, 0), 0.5)
	
	# Enable trigger
	get_child(0).disabled = false

func _on_body_entered(body: Node3D) -> void:
	_current_watering_amount += 1
	
	# Jiggle
	var tween : Tween = create_tween()
	tween.tween_property($"../Model", "scale", Vector3(1.1, 1.1, 1.1), 0.1)
	tween.tween_property($"../Model", "scale", Vector3.ONE, 0.1)
	
	if _event and _current_watering_amount >= _event.target_water_amount:
		# Reset mouth to default position
		var mouth_tween : Tween = create_tween().set_parallel(true)
		mouth_tween.tween_property($"../Model/Lower_Head", "rotation", Vector3(0.122173, 0, 0), 0.5)
		mouth_tween.tween_property($"../Model/Upper_Head", "rotation", Vector3(-0.8866273, 0, 0), 0.5)
		
		# Notify event
		_event.watering_completed()
		
		_cleanup()

func _cleanup() -> void:
	# Disable parent outline
	owner.set_outline(false)
	
	# Disable trigger
	get_child(0).disabled = true
	
	# Reset event reference
	_event = null
