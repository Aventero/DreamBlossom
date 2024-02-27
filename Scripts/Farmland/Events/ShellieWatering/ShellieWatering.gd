@icon("res://Textures/EditorIcons/WaterDrop.png")
class_name ShellieWatering
extends Node3D

@onready var outline : MeshInstance3D = $Outline
@onready var trigger : CollisionShape3D = $Trigger/Shape
@onready var material_changer : MaterialChanger = $MaterialChanger

var _coral_mesh : MeshInstance3D
var _watering_event : ShellieWateringEvent
var _current_watering_amount : int = 0
var _target_watering_amount : int

func setup(coral_mesh : MeshInstance3D, event : ShellieWateringEvent):
	# Set data
	_coral_mesh = coral_mesh
	_watering_event = event
	
	_current_watering_amount = 0
	_target_watering_amount = _watering_event.watering_amount
	
	var tween : Tween = create_tween()
	tween.tween_property(coral_mesh, "scale", Vector3(1.1, 1.1, 1.1), 0.1)
	tween.tween_callback(_enable_watering)
	tween.tween_property(coral_mesh, "scale", Vector3.ONE, 0.1)

func _enable_watering():
	outline.visible = true
	trigger.disabled = false
	
	material_changer.set_state_by_name("Wet_4")

func _disable_watering():
	outline.visible = false
	trigger.disabled = true

func _on_trigger_body_entered(body):
	body.queue_free()
	
	_current_watering_amount += 1
	
	var tween : Tween = create_tween()
	tween.tween_property(_coral_mesh, "scale", Vector3(1.1, 1.1, 1.1), 0.1)
	tween.tween_callback(material_changer.previous_state)
	tween.tween_property(_coral_mesh, "scale", Vector3.ONE, 0.1)
	
	await tween.finished
	
	if _current_watering_amount >= _target_watering_amount:
		_disable_watering()
		_watering_event.coral_watered()
