@icon("res://Textures/WeedSpot.png")
class_name Weed
extends Node3D

@export_category("Rumble")
@export var pull_rumble : XRToolsRumbleEvent

@export_category("Pull Settings")
@export_range(1, 5.0) var max_stretch : float
@export var min_pull_distance : float
@export var target_pull_distance : float
@export_range(0, 1) var pull_particle_offset : float

@export_category("Pull Animation")
@export var max_shake : float
@export var max_speed : float

@export_category("Particles")
@export var particles_height_offset : float
@export var pull_particles : PackedScene
@export var pull_complete_particles : PackedScene

@onready var weed : Node3D = $"Weed Model"
@onready var pickable_pull : XRToolsPickable = $"Pull Origin/Pull Pickup"

var pull_particle_instance : GPUParticles3D
var time : float = 0.0
var initial_scale : Vector3

func _ready():
	initial_scale = get_parent().scale

func _process(delta):
	time += delta
	
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
	_weed_pull_animation(ratio)
	
	# Stretch
	weed.scale.y = (ratio * (max_stretch - 1.0)) + 1.0
	
	# Spawn pull particles
	if ratio > pull_particle_offset and pull_particle_instance == null:
		var pull_parts : GPUParticles3D = pull_particles.instantiate()
		add_child(pull_parts)
		
		# Move particles to correct position and rotation
		pull_parts.position = Vector3(0, particles_height_offset, 0)
		pull_parts.rotation = Vector3.UP
		
		pull_particle_instance = pull_parts
	else:
		# Despawn particles if there is one
		if not pull_particle_instance == null:
			pull_particle_instance.one_shot = true
			pull_particle_instance.emitting = false
			pull_particle_instance = null
	
	# Check if target distance is reached
	if distance > target_pull_distance:
		# Spawn pull complete particles
		var pull_complete_parts : GPUParticles3D = pull_complete_particles.instantiate()
		add_child(pull_complete_parts)
		
		# Move particles to correct position and rotation
		pull_complete_parts.position = Vector3(0, particles_height_offset, 0)
		pull_complete_parts.rotation = Vector3.UP
		pull_complete_parts.emitting = true
		
		# Drop pull
		pickable_pull.drop()
		pickable_pull.enabled = false
		_on_pull_completed()
		
func _on_pull_completed():
	weed.queue_free()

func _weed_pull_animation(ratio):
	weed.position = Vector3(
		sin(time * max_speed) * ratio * max_shake,
		weed.position.y,
		cos(time * max_speed) * ratio * max_shake
	)
	
	weed.rotation = Vector3(
		0,
		sin(time * max_speed) * ratio * 0.1,
		cos(time * max_speed) * ratio * 0.1
	)

func _on_pull_pickup_dropped(pickable):
	var tween : Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(weed, "scale", Vector3.ONE, 0.1)
	pickable.position = Vector3.ZERO
	pickable.rotation = Vector3.ZERO
	
	time = 0.0
	
	# Remove pull rumble haptic
	XRToolsRumbleManager.clear("pull_rumble")
	
	# Remove pull particles
	if not pull_particle_instance == null:
		pull_particle_instance.one_shot = true
		pull_particle_instance.emitting = false
		pull_particle_instance = null

