extends Node3D

@export var pull_distance : float
@export var put_rumble : XRToolsRumbleEvent
@export var pull_rumble : XRToolsRumbleEvent

@export var max_shake : float
@export var max_speed : float

@export var insert_particles : PackedScene
@export var pull_particles : PackedScene
@export var pull_complete_particles : PackedScene

@onready var pickable_shovel : XRToolsPickable = $".."
@onready var pickable_pull : XRToolsPickable = $"../PullOrigin/PullPickup"
@onready var intersection_raycast : RayCast3D = $"../InsertionHitDetection"

@onready var shovel_pickup_collider : CollisionShape3D = $"../CollisionShape3D"
@onready var pull_origin : Node3D = $"../PullOrigin"
@onready var pull_pickup_collider : CollisionShape3D = $"../PullOrigin/PullPickup/CollisionShape3D"

var insert_position : Vector3
var insert_rotation : Vector3
var prev_position : Vector3
var velocity : float
var time : float = 0
var allow_insertion = true

var pull_particle_instance : GPUParticles3D

func _ready():
	prev_position = global_position

func _process(delta):
	time += delta
	
	# Skip calculates if not picked up
	if pickable_shovel.is_picked_up():
		# Calculate current velocity of shovel
		var current_position : Vector3 = global_position
		var delta_position : Vector3 = current_position - prev_position
		velocity = (delta_position / delta).x
		prev_position = current_position
	
	if pickable_pull.is_picked_up():
		# Calculate distance to origin
		var distance : float = (pickable_pull.global_position - pull_origin.global_position).length()
		
		# Adjust pull rumble haptics according to distance
		var ratio : float = distance / pull_distance
		pull_rumble.magnitude = ratio
		
		# Shake shovel depending on distance
		pickable_shovel.position = insert_position + Vector3(
			sin(time * max_speed) * ratio * max_shake,
			0,
			cos(time * max_speed) * ratio * max_shake
		)
		
		pickable_shovel.rotation = insert_rotation + Vector3(
			0,
			sin(time * max_speed) * ratio * 0.1,
			cos(time * max_speed) * ratio * 0.1
		)
		
		if distance > pull_distance:
			var function_pickup : XRToolsFunctionPickup = pickable_pull.get_picked_up_by()
			
			# Spawn particles
			var pull_complete_parts : GPUParticles3D = pull_complete_particles.instantiate()
			add_child(pull_complete_parts)
			pull_complete_parts.emitting = true
			
			_shovel_soil_leave()
			function_pickup._pick_up_object(pickable_shovel)

func _on_soil_trigger_body_entered(body):
	# Check if insertion is allowed
	if not allow_insertion:
		return
	
	# Check if shovel is currently held
	if not pickable_shovel.is_picked_up():
		return
	
	# Haptic feedback for shovel insert
	var controller : XRController3D = pickable_shovel.get_picked_up_by_controller()
	XRToolsRumbleManager.add(controller.name, put_rumble, [controller])
	
	# Spawn particles
	var particles = insert_particles.instantiate()
	add_child(particles)
	particles.emitting = true
	
	var function_pickup : XRToolsFunctionPickup = pickable_shovel.get_picked_up_by()
	
	# Disable Shovel and enable pull interactable
	insert_position = pickable_shovel.position
	insert_rotation = pickable_shovel.rotation
	_shovel_soil_insert()
	
	# Make player hold new pull object
	function_pickup._pick_up_object(pickable_pull)

func _shovel_soil_insert():
	# Disable pickup collider
	shovel_pickup_collider.disabled = true
	
	# Make player to drop shovel
	pickable_shovel.drop()

	# Make shovel static while frozen so it stays at current position
	pickable_shovel.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	pickable_shovel.freeze = true
	
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
	pickable_shovel.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	pickable_shovel.freeze = false

func _on_pull_pickup_dropped(pickable: XRToolsPickable):
	# Reset pull handle to origin
	pickable_pull.position = Vector3.ZERO
	pickable_pull.rotation = $"../PullOrigin".rotation
	
	# Remove pull rumble haptic
	XRToolsRumbleManager.clear("pull_rumble")
	
	# Remove pull particles
	if not pull_particle_instance == null:
		pull_particle_instance.one_shot = true
		pull_particle_instance.emitting = false
		pull_particle_instance = null

func _on_pull_pickup_picked_up(pickable: XRToolsPickable):
	# Add pull rumble haptic to correct controller
	var controller : XRController3D = pickable.get_picked_up_by_controller()
	XRToolsRumbleManager.add("pull_rumble", pull_rumble, [controller])
	
	# Spawn particle system
	var pull_parts : GPUParticles3D = pull_particles.instantiate()
	add_child(pull_parts)
	pull_particle_instance = pull_parts

func _on_handle_trigger_body_entered(body):
	allow_insertion = false

func _on_handle_trigger_body_exited(body):
	allow_insertion = true
