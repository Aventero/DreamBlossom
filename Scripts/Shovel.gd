@icon("res://Textures/shovel.png")
class_name Shovel
extends XRToolsPickable

# Emitted when shovel is inserted into soil
signal inserted(position: Vector3)

# Emitted when shovel pull started
signal pull_started

# Emitted when shovel pull ended
signal pull_stopped

# Emitted when shovel pull is completed
signal pull_completed

@export_category("General")
## Defines the minimum angle for inserting the shovel into the soil
@export var min_insertion_angle : float

@export_category("Rumble Haptics")
## This rumble plays when inserting the shovel into the soil
@export var put_rumble : XRToolsRumbleEvent
## This rumble plays when pulling the shovel out of the soil
@export var pull_rumble : XRToolsRumbleEvent

@export_category("Pull Animation")
## Defines how strong the shovel can shake during pull
@export var max_shake : float
## Defines how fast the shovel can shake during pull
@export var max_speed : float

@export_category("Pull Settings")
## Defines the minimum pull distance for rumble effect to occur
@export var min_pull_distance : float 
## Defines the pull distance to complete the shovel pull
@export var target_pull_distance : float
## Defines at which pull distance the pull particles are spawned. Given in % of pull distance.
@export_range(0, 1) var pull_particle_offset : float

@export_category("Particles")
## Defines the spawnpoint height offset to the soil intersection point
@export var particles_height_offset : float
## Defines particles on shovel insertion
@export var insert_particles : PackedScene
## Defines particles on shovel pull
@export var pull_particles : PackedScene
## Defines particles on complete shovel pull
@export var pull_complete_particles : PackedScene

@export_category("Dig Spot")
@export var dig_spot : PackedScene

@onready var pickable_pull : XRToolsPickable = $PullOrigin/PullPickup

@onready var shovel_pickup_collider : CollisionShape3D = $CollisionShape3D
@onready var pull_pickup_collider : CollisionShape3D = $"PullOrigin/PullPickup/CollisionShape3D"

@onready var intersection_raycast : RayCast3D = $"InsertionHitDetection"
@onready var pull_origin : Node3D = $"PullOrigin"

var pull_particle_instance : GPUParticles3D
var soil_insertion_point : Vector3
var pull_pickup_position : Vector3

var inserted_shovel_position : Vector3
var inserted_shovel_rotation : Vector3

var angle : float
var time : float = 0

func _process(delta):
	time += delta
	
	# Check insertion angle
	angle = rad_to_deg(transform.basis.x.angle_to(Vector3.UP))
	
	# Check if shovel pull is currently picked up
	if pickable_pull.is_picked_up():
		# Calculate current pull distance to pull pickup postiion
		var distance : float = (pickable_pull.global_position - pull_pickup_position).length()
		
		# Calculate current ratio of pulled distance minus min_pull_distance and target distance
		var ratio : float = max(0, (distance - min_pull_distance) / target_pull_distance)
		
		# Adjust pull rumble haptics according to ratio
		pull_rumble.magnitude = ratio
		
		# Animate shovel shake on pull
		_shovel_pull_animation(ratio)
		
		# Spawn pull particles
		if ratio > pull_particle_offset and pull_particle_instance == null:
			var pull_parts : GPUParticles3D = pull_particles.instantiate()
			add_child(pull_parts)
			
			# Move particles to correct position and rotation
			pull_parts.global_position = soil_insertion_point + Vector3(0, particles_height_offset, 0)
			pull_parts.global_rotation = Vector3.UP
			
			pull_particle_instance = pull_parts
		else:
			# Despawn particles if there is one
			if not pull_particle_instance == null:
				pull_particle_instance.one_shot = true
				pull_particle_instance.emitting = false
				pull_particle_instance = null
		
		# Check if pull distance reached target distance
		if distance > target_pull_distance:
			var controller_pickup : XRToolsFunctionPickup = pickable_pull.get_picked_up_by()
			
			# Spawn pull complete particles
			var pull_complete_parts : GPUParticles3D = pull_complete_particles.instantiate()
			add_child(pull_complete_parts)
			
			# Move particles to correct position and rotation
			pull_complete_parts.global_position = soil_insertion_point + Vector3(0, particles_height_offset, 0)
			pull_complete_parts.global_rotation = Vector3.UP
			
			pull_complete_parts.emitting = true
			
			_shovel_soil_leave()
			
			# Spawn dig spot
			var dig_spot_instance = dig_spot.instantiate()
			$"..".add_child(dig_spot_instance)
			dig_spot_instance.global_position = soil_insertion_point
			
			# Emit completed pull
			pull_completed.emit()
			
			# Force player to pick up shovel again
			controller_pickup._pick_up_object(self)

func _shovel_pull_animation(ratio):
	position = inserted_shovel_position + Vector3(
		sin(time * max_speed) * ratio * max_shake,
		0,
		cos(time * max_speed) * ratio * max_shake
	)
	
	rotation = inserted_shovel_rotation + Vector3(
		0,
		sin(time * max_speed) * ratio * 0.1,
		cos(time * max_speed) * ratio * 0.1
	)

func _on_soil_trigger_body_entered(body):
	# Check if insertion is allowed
	if not insertion_allowed():
		return
	
	# Check if shovel is currently held
	if not is_picked_up():
		return
	
	# Haptic feedback for shovel insert
	var controller : XRController3D = get_picked_up_by_controller()
	XRToolsRumbleManager.add(controller.name, put_rumble, [controller])
	
	# Get intersection point with soil
	soil_insertion_point = intersection_raycast.get_collision_point()
	
	# Spawn insertion particles
	var particles : GPUParticles3D = insert_particles.instantiate()
	add_child(particles)
	
	# Move particles to correct position and rotation
	particles.global_position = soil_insertion_point + Vector3(0, particles_height_offset, 0)
	particles.global_rotation = Vector3.UP
	particles.emitting = true
	
	# Save current transform of shovel for pull animation
	inserted_shovel_position = position
	inserted_shovel_rotation = rotation
	
	var controller_pickup : XRToolsFunctionPickup = get_picked_up_by()
	
	# Disable Shovel and enable pull interactable
	_shovel_soil_insert()
	
	# Emit insert signal
	inserted.emit()
	
	# Make player hold new pull object
	controller_pickup._pick_up_object(pickable_pull)

func _shovel_soil_insert():
	# Disable pickup collider
	shovel_pickup_collider.disabled = true
	
	# Make player to drop shovel
	drop()

	# Make shovel static while frozen so it stays at current position
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	
	# Enable pull pickable
	pickable_pull.enabled = true
	pull_origin.visible = true
	pull_pickup_collider.disabled = false

func _shovel_soil_leave():
	# Disable pull pickable
	pickable_pull.drop()
	pickable_pull.enabled = false
	pull_pickup_collider.disabled = true
	pull_origin.visible = false
	
	# Reactivate shovel
	shovel_pickup_collider.disabled = false
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = false

func insertion_allowed():
	if angle < 90.0 + min_insertion_angle:
		return false
	return true

func _on_pull_pickup_picked_up(pickable: XRToolsPickable):
	# Add pull rumble haptic to correct controller
	var controller : XRController3D = pickable.get_picked_up_by_controller()
	XRToolsRumbleManager.add("pull_rumble", pull_rumble, [controller])
	
	# Save current controller position as pull origin
	pull_pickup_position = controller.global_position
	
	pull_started.emit()

func _on_pull_pickup_dropped(pickable: XRToolsPickable):
	# Reset pull handle to origin
	pickable_pull.position = Vector3.ZERO
	pickable_pull.rotation = pull_origin.rotation
	
	# Remove pull rumble haptic
	XRToolsRumbleManager.clear("pull_rumble")
	
	# Remove pull particles
	if not pull_particle_instance == null:
		pull_particle_instance.one_shot = true
		pull_particle_instance.emitting = false
		pull_particle_instance = null
	
	pull_stopped.emit()

