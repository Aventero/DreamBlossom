@icon("res://Textures/EditorIcons/WeedSpot.png")
class_name WeedSpot
extends Node3D

@export_range(0.0, 1.0, 0.01) var spread_chance : float 

@export_category("Rumble")
@export var pull_rumble : XRToolsRumbleEvent

@export_category("Pull Settings")
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
var cell : GridCell
var time : float = 0.0
var initial_scale

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
		
		weed.queue_free()
		
		# Remove weed from soil logically
		WeedManager.get_instance().remove_weed(cell, cell.grid)
		
		# Start remove animation
		var remove_tween = create_tween()
		remove_tween.tween_property(self, "global_position", global_position + Vector3(0, -0.2, 0), 1.0)
		remove_tween.tween_callback(Callable(_free_callback))

func _free_callback():
	queue_free()

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

func _on_spread_timer_timeout():
	if not randf() < spread_chance:
		return
	
	# Get all surrounding cells
	var surrounding_cells : Array[GridCell] = cell.grid.get_cells(cell, 3, false)
	var possible_cells : Array[GridCell]
	
	for s_cell in surrounding_cells:
		if not s_cell.occupied:
			possible_cells.append(s_cell)
	
	# Get random cell
	if possible_cells.size() == 0:
		return
	
	var random_cell : GridCell = possible_cells[randi_range(0, possible_cells.size() - 1)]
	
	#WeedManager.get_instance().spawn_weed(random_cell, random_cell.grid)

func _on_pull_pickup_picked_up(pickable):
	# Squish on first pickup
	_grab_squish()
	
	# Add pull rumble haptic to correct controller
	var controller : XRController3D = pickable.get_picked_up_by_controller()
	XRToolsRumbleManager.add("pull_rumble", pull_rumble, [controller])

func _on_pull_pickup_dropped(pickable):
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

func _grab_squish():
	var dig_spot = $"Dig Spot Model"
	initial_scale = dig_spot.scale
	var tween : Tween = create_tween()
	
	var shrinked_scale = Vector3(initial_scale.x * 0.9, initial_scale.y * 0.9, initial_scale.z * 0.9)
	tween.tween_property(dig_spot, "scale", shrinked_scale, 0.05)

func _on_pull_pickup_released(pickable, by):
	var dig_spot = $"Dig Spot Model"
	var tween : Tween = create_tween()
	tween.tween_property(dig_spot, "scale", initial_scale, 0.1)
