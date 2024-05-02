class_name Lever
extends Node3D

signal pulled()

@export var pull_rumble : XRToolsRumbleEvent
@export var pull_complete_rumble : XRToolsRumbleEvent

@onready var grab_pickable : XRToolsPickable = $"Grab Pickable"
@onready var grab_origin : Node3D = $"../Model/LeverStick/Grab Origin"
@onready var lever_model : Node3D = $"../Model/LeverStick"
@onready var lever_pull_particles : ParticleCombiner = $"../LeverPulledCombiner"

# Smoke Particles
@onready var smoke : Array[GPUParticles3D] = [
	$"../LeverPulledCombiner/Smoke1",
	$"../LeverPulledCombiner/Smoke2"
]

var _lower_angle : float = -deg_to_rad(56)
var _upper_angle : float = deg_to_rad(56)

var _retract_tween : Tween
var _ignore_drop : bool = false
var _controller : XRController3D

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
	
	# Change rumble strength
	pull_rumble.magnitude = 0.5 * ((angle - _lower_angle) / 1.954769) # Map current angle to Range 0.0 <---> 0.5
	
	# Check if lever reached end
	if angle < _upper_angle:
		return
	
	# Play pull complete rumble
	XRToolsRumbleManager.add("cauldron_pull_complete", pull_complete_rumble, [_controller])
	
	# Force player to drop lever (Ignore lerp back)
	_ignore_drop = true
	grab_pickable.drop()
	
	# Play particles (Smoke too if cauldron is empty)
	var cauldron_empty : bool = owner.get_mixture() == 0
	for s in smoke:
		s.visible = cauldron_empty
	lever_pull_particles.start()
	
	# Disable pickable
	grab_pickable.enabled = false
	
	var tween : Tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_method(_retract, _upper_angle, _lower_angle,2.0)
	
	# Emit pulled event
	pulled.emit()
	
	# Renable grab after tween
	await tween.finished
	_ignore_drop = false
	grab_pickable.enabled = true

func _on_grip_pickable_picked_up(pickable: XRToolsPickable) -> void:
	# Save controller
	_controller = pickable.get_picked_up_by_controller()
	
	# Add pull rumble
	XRToolsRumbleManager.add("cauldron_pull", pull_rumble, [_controller])
	
	# Kill retraction tween
	if _retract_tween and _retract_tween.is_running():
		_retract_tween.kill()

func _on_grip_pickable_dropped(pickable: Variant) -> void:
	# Remove rumble
	XRToolsRumbleManager.clear("cauldron_pull", [_controller])
	_controller = null
	
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
