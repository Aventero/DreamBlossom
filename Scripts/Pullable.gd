@icon("res://Textures/Pullable.png")
class_name Pullable
extends Node3D

signal started;
signal released;
signal completed;

@export_category("Rumble")
@export var pickup_rumble : XRToolsRumbleEvent
@export var pull_rumble : XRToolsRumbleEvent
@export var complete_rumble : XRToolsRumbleEvent

@export_category("Pull Settings")
@export_range(1, 5.0) var max_stretch : float
@export var min_pull_distance : float
@export var target_pull_distance : float
@export_range(0, 1) var pull_particle_offset : float

@export_category("Particles")
@export var pull_particles : PackedScene
@export var pull_particles_offset : Vector3
@export var pull_complete_particles : PackedScene
@export var pull_complete_particles_offset : Vector3

@onready var model : Node3D = $Model
@onready var pickable_pull : XRToolsPickable = $"Pull Origin/Pull Pickup"

@export_category("Debug")
@export var draw_debug : bool = false

var pull_particle_instance : ParticleCombiner
var picked_by : XRController3D = null
var time : float = 0.0

func _process(delta):
	time += delta
	
	if draw_debug:
		DebugDraw3D.draw_sphere(pickable_pull.global_position, 0.025)
	
	if pickable_pull.is_picked_up():
		_handle_pull()

func _handle_pull():
	# Calculate current pull distance to origin (Vector Zero)
	var distance : float = pickable_pull.position.length()
	
	# Calculate current ratio of pulled distance minus min_pull_distance and target distance
	var ratio : float = max(0, (distance - min_pull_distance) / target_pull_distance)
	
	# Adjust pull rumble haptics according to ratio
	pull_rumble.magnitude = ratio
	
	# Play jiggle animation
	_pull_animation(ratio)
	
	# Stretch
	model.scale.y = (ratio * (max_stretch - 1.0)) + 1.0
	
	# Spawn pull particles
	if ratio > pull_particle_offset:
		if pull_particle_instance == null:
			var pull_parts : ParticleCombiner = pull_particles.instantiate()
			add_child(pull_parts)
			
			# Move particles to correct position
			pull_parts.position = pull_particles_offset
			
			pull_particle_instance = pull_parts
			pull_particle_instance.start()
	else:
		# Despawn particles if there is one
		if not pull_particle_instance == null:
			pull_particle_instance.stop()
			pull_particle_instance = null
	
	# Check if target distance is reached
	if distance > target_pull_distance:
		# Spawn pull complete particles
		var pull_complete_parts : ParticleCombiner = pull_complete_particles.instantiate()
		add_sibling(pull_complete_parts)
		
		# Move particles to correct position
		pull_complete_parts.position = pull_complete_particles_offset
		
		# Complete rumble
		XRToolsRumbleManager.add("pull_complete", complete_rumble, [picked_by])
		
		# Drop pull
		pickable_pull.drop()
		pickable_pull.enabled = false
		
		completed.emit()
		_on_pull_completed()

# Override with custom function
func _on_pull_completed():
	pass

# Override with custom animation
func _pull_animation(ratio):
	model.position = Vector3(
		sin(time * 20) * ratio * 0.005,
		model.position.y,
		cos(time * 20) * ratio * 0.005
	)
	
	model.rotation = Vector3(
		0,
		sin(time * 20) * ratio * 0.1,
		cos(time * 20) * ratio * 0.1
	)

func _on_pull_pickup_dropped(pickable):
	pickable_pull.enabled = false
	
	var tween : Tween = create_tween()
	tween.tween_property(model, "scale", Vector3.ONE, 0.1)
	tween.tween_callback(func(): pickable_pull.enabled = true)
	
	pickable_pull.scale = Vector3.ONE
	pickable_pull.position = Vector3.ZERO
	pickable_pull.rotation = Vector3.ZERO
	
	time = 0.0
	pull_rumble.magnitude = 0.0
	picked_by = null
	
	# Remove pull rumble haptic
	XRToolsRumbleManager.clear("pull_rumble")
	
	# Remove pull particles
	if not pull_particle_instance == null:
		pull_particle_instance.stop()
		pull_particle_instance = null
	
	released.emit()

func _on_pull_pickup_picked_up(pickable):
	# Squish on first pickup
	_on_grab()
	
	picked_by = pickable.get_picked_up_by_controller()
	
	# Pickup rumble
	XRToolsRumbleManager.add("pickup", pickup_rumble, [picked_by])
	
	# Add pull rumble haptic to correct controller
	XRToolsRumbleManager.add("pull_rumble", pull_rumble, [picked_by])
	
	started.emit()

# Override with custom function
func _on_grab():
	var tween : Tween = create_tween()
	tween.tween_property(model, "scale", Vector3(0.9, 0.9, 0.9), 0.05)
