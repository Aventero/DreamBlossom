class_name Lever
extends Node3D

signal pulled()

@onready var grab_pickable : XRToolsPickable = $"Grab Pickable"
@onready var grab_origin : Node3D = $"../Model/LeverStick/Grab Origin"
@onready var lever_model : Node3D = $"../Model/LeverStick"
@onready var lever_pull_particles : ParticleCombiner = $"../LeverPulledCombiner"

var _lower_angle : float = -deg_to_rad(56)
var _upper_angle : float = deg_to_rad(56)

var _retract_tween : Tween

var _ignore_drop : bool = false

func _process(delta: float) -> void:
	if not grab_pickable.is_picked_up():
		return
	
	# Calculate direction to hand
	var direction = grab_pickable.position - lever_model.position
	
	# Skip processing if hand is below lever
	if direction.y < 0.0:
		return
	
	# Calculate new angle for lever
	var angle = direction.signed_angle_to(Vector3(0.0, 0.0, 1.0), Vector3(1.0, 0.0, 0.0)) - PI / 2.0
	angle = clamp(-angle, _lower_angle, _upper_angle)
	
	# Set new rotation
	lever_model.rotation = Vector3(angle, 0.0, 0.0)
	
	# Check if lever reached end
	if angle < _upper_angle:
		return
	
	pulled.emit()
	
	# Force player to drop lever (Ignore lerp back
	_ignore_drop = true
	grab_pickable.drop()
	
	# Play particles
	lever_pull_particles.start()
	
	# Disable pickable
	grab_pickable.enabled = false
	
	var tween : Tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_method(_retract, _upper_angle, _lower_angle,2.0)
	
	# Renable grab after tween
	await tween.finished
	_ignore_drop = false
	grab_pickable.enabled = true

func _on_grip_pickable_picked_up(pickable: Variant) -> void:
	# Kill retraction tween
	if _retract_tween and _retract_tween.is_running():
		_retract_tween.kill()

func _on_grip_pickable_dropped(pickable: Variant) -> void:
	if _ignore_drop:
		return
	
	# Start retraction
	_retract_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	_retract_tween.tween_method(_retract, lever_model.rotation.x, _lower_angle, 1.0)

func _retract(angle : float) -> void:
	lever_model.rotation = Vector3(angle, 0.0, 0.0)
	
	# Update pickable position
	grab_pickable.global_position = grab_origin.global_position
	grab_pickable.rotation = Vector3(angle, 0.0, 0.0)
