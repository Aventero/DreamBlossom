@icon("res://Textures/EditorIcons/Shovel.png")
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
@export var lerp_speed : float

@export_category("Rumble Haptics")
## This rumble plays when inserting the shovel into the soil
@export var put_rumble : XRToolsRumbleEvent
## This rumble plays when pulling the shovel out of the soil
@export var pull_rumble : XRToolsRumbleEvent
## This rumble plays when pull is completed
@export var complete_rumble : XRToolsRumbleEvent

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

@export_category("Shovel Settings")
@export var shovel_settings : Array[ShovelSetting]

@onready var pickable_pull : XRToolsPickable = $PullOrigin/PullPickup

@onready var shovel_pickup_collider : CollisionShape3D = $CollisionShape3D
@onready var pull_pickup_collider : CollisionShape3D = $"PullOrigin/PullPickup/CollisionShape3D"
@onready var soil_trigger : CollisionShape3D = $SoilTrigger/Trigger

@onready var intersection_raycast : RayCast3D = $"InsertionHitDetection"
@onready var pull_origin : Node3D = $"PullOrigin"

@onready var snapping_raycast : RayCast3D = $Snapping
@onready var shovel_intersection_indicator : MeshInstance3D = $"Intersection Point"

var pull_particle_instance : GPUParticles3D
var soil_insertion_point : Vector3
var pull_pickup_position : Vector3

var inserted_shovel_position : Vector3
var inserted_shovel_rotation : Vector3

var angle : float
var time : float = 0

var controller : XRController3D

# Defines current shovel setting (Indicator, Digspot and size)
var current_setting_index : int = 0

# Hold current indicator instance
var indicator_instance : Indicator = null

# Hold currently selected cell
var current_cell : GridCell = null
var current_cell_pos : Vector3
var allowed_insertion : bool = false
var previous_cell_pos : Vector3

func _ready():
	super()
	
	# Spawn first indicator
	indicator_instance = shovel_settings[current_setting_index].indicator.instantiate()
	add_child(indicator_instance)

func _process(delta):
	time += delta
	
	# Check insertion angle
	angle = rad_to_deg(transform.basis.x.angle_to(Vector3.UP))
	
	# Check if shovel is currently hold
	if is_picked_up():
		_handle_shovel()
	
	# Check if shovel pull is currently hold
	if pickable_pull.is_picked_up():
		_handle_shovel_pull()

func _handle_shovel():
	if not intersection_raycast.is_colliding():
		# Reset previously selected cell
		current_cell = null
		allowed_insertion = false
		indicator_instance.set_state(Indicator.STATE.HIDDEN)
		indicator_instance.ignore_lerp = true
		shovel_intersection_indicator.visible = false
		return
	
	var hit : Node3D = intersection_raycast.get_collider()
	
	if not hit.is_in_group("Soil"):
		# Reset previously selected cell
		current_cell = null
		allowed_insertion = false
		indicator_instance.set_state(Indicator.STATE.HIDDEN)
		indicator_instance.ignore_lerp = true
		shovel_intersection_indicator.visible = false
		return
	
	# Update intersection indicator
	shovel_intersection_indicator.visible = true
	shovel_intersection_indicator.global_position = intersection_raycast.get_collision_point() + Vector3(0.0, 0.02, 0.0)
	shovel_intersection_indicator.global_rotation = Vector3(-PI/2, 0.0, 0.0)
	
	# Convert hit to plant grid
	var grid : PlantGrid = hit
	
	# Find cell which is closest to intersection point
	var cell : GridCell = grid.get_cell(intersection_raycast.get_collision_point())
	
	if not cell:
		return
	
	# Find closest cell which is inbound. Only applies to border cells
	var inbound_cell : GridCell = grid.find_inbound_cell(cell, shovel_settings[current_setting_index].cell_width)
	
	# If current placement is allowed => Place indicator & Update cell
	if grid.is_placement_allowed(inbound_cell, shovel_settings[current_setting_index].cell_width):
		current_cell = inbound_cell
		allowed_insertion = true
		indicator_instance.set_state(Indicator.STATE.ALLOWED)
	else:
		# Update indicator position if new cell is occupied or indicator is restricted / hidden
		if cell.occupied or indicator_instance.state == Indicator.STATE.RESTRICTED or indicator_instance.state == Indicator.STATE.HIDDEN:
			current_cell = inbound_cell
			allowed_insertion = false
			indicator_instance.set_state(Indicator.STATE.RESTRICTED)
		else:
			# Move snapping raycast to correct position / rotation
			snapping_raycast.global_position = intersection_raycast.get_collision_point() + Vector3(0.0, 0.5, 0.0)
			snapping_raycast.global_rotation = Vector3.ZERO
			
			# Shovel leaves snapped indicator -> Move snapped cell
			if not snapping_raycast.is_colliding():
				current_cell = inbound_cell
				allowed_insertion = false
				indicator_instance.set_state(Indicator.STATE.RESTRICTED)
	
	# Move indicator to correct cell position
	current_cell_pos = grid.get_placement_position(current_cell, shovel_settings[current_setting_index].cell_width)
	
	# Ignore lerp if indicator is not currently spawned in
	if indicator_instance.ignore_lerp:
		indicator_instance.global_position = current_cell_pos
		indicator_instance.ignore_lerp = false
	else:
		var movement_lerp : Tween = create_tween()
		movement_lerp.tween_property(indicator_instance, "global_position", current_cell_pos, lerp_speed)
	
	indicator_instance.global_rotation = Vector3.ZERO
	
	# Play scale jiggle if new cell selected
	if current_cell_pos != previous_cell_pos:
		var scale_lerp : Tween = create_tween()
		scale_lerp.tween_property(indicator_instance, "scale", Vector3(0.9, 0.9, 0.9), 0.1)
		scale_lerp.tween_property(indicator_instance, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
		
		previous_cell_pos = current_cell_pos

func _handle_shovel_pull():
	# Calculate current pull distance to pull pickup position
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
		pull_parts.global_position = current_cell_pos + Vector3(0, particles_height_offset, 0)
		pull_parts.global_rotation = Vector3.ZERO
		
		pull_particle_instance = pull_parts
	else:
		# Despawn particles if there is one
		if not pull_particle_instance == null:
			pull_particle_instance.one_shot = true
			pull_particle_instance.emitting = false
			pull_particle_instance = null
	
	# Check if pull distance reached target distance
	if distance > target_pull_distance:
		_handle_complete_pull()

func _handle_complete_pull():
	var controller_pickup : XRToolsFunctionPickup = pickable_pull.get_picked_up_by()
	
	# Spawn pull complete particles
	var pull_complete_parts : GPUParticles3D = pull_complete_particles.instantiate()
	add_child(pull_complete_parts)
	
	# Move particles to correct position and rotation
	pull_complete_parts.global_position = soil_insertion_point + Vector3(0, 0.1, 0)
	pull_complete_parts.global_rotation = Vector3.UP
	pull_complete_parts.emitting = true
	
	# Play complete rumble
	XRToolsRumbleManager.add("complete_rumble", complete_rumble, [controller])
	
	# Reenable shovel
	_shovel_soil_leave()
	
	# Spawn dig spot
	var dig_spot_instance = shovel_settings[current_setting_index].dig_spot.instantiate()
	$"..".add_child(dig_spot_instance)
	dig_spot_instance.global_position = current_cell_pos - Vector3(0.0, 0.1, 0.0)
	dig_spot_instance.anchor_cell = current_cell
	dig_spot_instance.cell_width = shovel_settings[current_setting_index].cell_width
	
	# Move digspot out of soil
	var tween : Tween = create_tween()
	tween.tween_property(dig_spot_instance, "global_position", current_cell_pos, 0.1)
	
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
	# Check if current angle of shovel is allowed for insertion
	if not _insertion_angle_allowed():
		return
	
	# Check if shovel is currently held
	if not is_picked_up():
		return
	
	# Check if current cell is valid
	if not allowed_insertion:
		return
	
	# Haptic feedback for shovel insert
	var controller : XRController3D = get_picked_up_by_controller()
	XRToolsRumbleManager.add(controller.name, put_rumble, [controller])
	
	# Squish feedback of insertion
	_insertion_squish()
	
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
	
	# Occupy space on grid
	current_cell.grid.set_state(current_cell, shovel_settings[current_setting_index].cell_width, true)
	
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
	
	# Disable soil trigger for a set amount of time
	var soil_trigger_tween : Tween = create_tween()
	soil_trigger_tween.tween_callback(func(): soil_trigger.disabled = true)
	soil_trigger_tween.tween_interval(0.2)
	soil_trigger_tween.tween_callback(func(): soil_trigger.disabled = false)
	
	# Reactivate shovel
	shovel_pickup_collider.disabled = false
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = false

func _insertion_angle_allowed():
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

func _on_picked_up(pickable : XRToolsPickable):
	# Connect input change event from current controller
	controller = pickable.get_picked_up_by_controller()
	controller.input_vector2_changed.connect(Callable(_controller_input_change))

func _on_dropped(pickable : XRToolsPickable):
	# Remove input change event
	controller.input_vector2_changed.disconnect(Callable(_controller_input_change))
	
	indicator_instance.set_state(Indicator.STATE.HIDDEN)
	shovel_intersection_indicator.visible = false

func _controller_input_change(name: String, value: Vector2):
	if name == "primary":
		# Check right movement of stick
		if value.x == 1.0:
			change_setting(1)
		
		# Check left movement of stick
		if value.x == -1.0:
			change_setting(-1)

func change_setting(offset : int):
	# Change current dig spot level accordingly
	current_setting_index = (current_setting_index + offset + shovel_settings.size()) % shovel_settings.size()
	
	# Despawn old indicator
	if indicator_instance:
		indicator_instance.queue_free()
	
	# Spawn new one
	indicator_instance = shovel_settings[current_setting_index].indicator.instantiate()
	add_child(indicator_instance)

func _insertion_squish():
	# Get the mesh
	var shovel_mesh : MeshInstance3D = $Shovel
	var initial_scale = shovel_mesh.scale
	var tween : Tween = create_tween()
	
	# Longate (increase length)
	var longated_scale = Vector3(initial_scale.x, initial_scale.y, initial_scale.z  * 1.1)
	tween.tween_property(shovel_mesh, "scale", longated_scale, 0.05)

	# Widen (increase width)
	var widened_scale = Vector3(initial_scale.x * 1.1, initial_scale.y * 1.1, initial_scale.z)
	tween.tween_property(shovel_mesh, "scale", widened_scale, 0.05)

	# Return to normal
	tween.tween_property(shovel_mesh, "scale", initial_scale, 0.05)

