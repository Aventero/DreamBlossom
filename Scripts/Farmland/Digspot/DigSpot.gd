@icon("res://Textures/EditorIcons/DigSpot.png")
class_name DigSpot
extends AnimatableBody3D

signal watering_completed

signal potion_added(type : Potion.TYPE)

@export_category("Interaction")
@export var hand_removal : bool = true
@export var seed_insertion : bool = true
@export var watering : bool = true
@export var fertilizing : bool = true

@export_category("General")
@export var remove_amount : float
@export var watering_amount : int

@export_category("Jiggel Settings")
@export var max_jiggle : float
@export var max_jiggle_speed : float

@export_category("Particles")
@export var remove_particles : PackedScene
@export var seed_insert_particles : PackedScene

@onready var seed_snap_point : Node3D = $"Seed Snap Point"
@onready var material_changer : MaterialChanger = $MaterialChanger
@onready var dry_timer : Timer = $DryTimer
@export var outline_mesh : MeshInstance3D

var anchor_cell : GridCell

# Removing function
var progress : float
var hand : XRToolsCollisionHand
var previous_hand_position : Vector3

# Seed / Plant
var grow_seed : Seed = null
var plant : Node3D = null

# Watering
var current_water : int = 0

var jiggle_tween : Tween

var time : float = 0.0
var to_be_deleted : bool = false

func _ready():
	# Add self to lookup
	DigSpotLookup.add(self)

func _process(delta):
	# Skip update if spot is currently in remove tween / animation
	if to_be_deleted:
		return
	
	# Remove jiggle timer
	time += delta
	
	# Animate tile according to progress
	if (progress > 0.0):
		var ratio : float = progress / remove_amount
		
		# Jiggle depending on time and current ratio
		var jiggle : float = sin(time * max_jiggle_speed) * max_jiggle * ratio
		rotation = Vector3(0, deg_to_rad(jiggle), 0)
	
	# Skip next steps if no player hand is currently here
	if not hand:
		return
	
	# Calculate traveled distance / new progress
	var distance : float = hand.global_position.distance_to(previous_hand_position)
	previous_hand_position = hand.global_position
	
	progress += distance
	
	# Check if "remove motion" is complete
	if progress > remove_amount:
		print("progress > remove_amount")
		remove_self()

func remove_self():
	print("REMOVING SELF")
	# Free occupied cells in grid
	anchor_cell.grid.set_state(anchor_cell, 2, GridCell.CELLSTATE.FREE)
	
	# Spawn remove particles
	var particles : GPUParticles3D = remove_particles.instantiate()
	add_child(particles)
	particles.position = Vector3(0, 0.2, 0)
	particles.emitting = true
	
	# Start remove animation
	var remove_tween = create_tween()
	remove_tween.tween_property(self, "global_position", global_position + Vector3(0, -0.2, 0), 2.0)
	remove_tween.tween_callback(Callable(_free_callback))
	
	# Spawn random obstacles
	WeedManager.get_instance().spawn_obstacles(anchor_cell)
	
	# Update Lookup
	DigSpotLookup.remove(self)
	
	to_be_deleted = true

func _free_callback():
	queue_free()

func _on_trigger_body_entered(body):
	# Check if body is hand
	if hand_removal and body is XRToolsCollisionHand:
		_handle_hand_movement(body)
	
	# Check if body is grow_seed
	if seed_insertion and not grow_seed and body is Seed and body.planted == false:
		# Ensure that grow_seed is only planted once
		grow_seed = body
		grow_seed.planted = true
		
		_handle_seed_insert()
	
	# Check if body is waterdrop
	if watering and body is WaterDrop and current_water < watering_amount:
		_handle_water_drop()
	
	# Check if body is PotionDrop
	if fertilizing and body is PotionDrop and potion_added.get_connections().size() > 0:
		# Emit potion added signal
		potion_added.emit(body.type)

func _handle_hand_movement(body : Node3D):
	# Check if hand is currently holding a object
	var function_pickup : XRToolsFunctionPickup = body.get_node("FunctionPickup")
	
	if not function_pickup or function_pickup.picked_up_object:
		return
	
	# Save current hand
	hand = body
	previous_hand_position = body.global_position

func _handle_seed_insert():
	# Force player to drop grow_seed
	grow_seed.drop()
	
	# Disable pickable from grow_seed
	grow_seed.enabled = false
	grow_seed.freeze = true
	
	# Disable inactivity manager
	InactivityManager.get_instance().remove_node(grow_seed)
	
	# Stop watering timer
	dry_timer.stop()
	
	# Reset rotation and place grow_seed to snap point
	var tween : Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(grow_seed, "rotation", Vector3.ZERO, 0.05)
	tween.tween_property(grow_seed, "global_position", seed_snap_point.global_position, 0.05)
	
	# Play jiggle animation for dig spot
	play_jiggle()
	
	# Spawn particles
	var particles : GPUParticles3D = seed_insert_particles.instantiate()
	add_child(particles)
	particles.position = seed_snap_point.position + Vector3(0, 0.1, 0)
	particles.emitting = true
	
	# Reparent grow_seed after tween
	tween.tween_callback(Callable(_reparent_seed_callback))
	
	# Spawn plant if water is enough
	if current_water >= watering_amount:
		_spawn_plant()

func _handle_water_drop():
	# Added a drop of water
	current_water += 1
	
	# Change material to next state
	play_jiggle(0.05)
	material_changer.next_state()
	
	# Check if fully watered
	if current_water != watering_amount:
		# Start dry timer if not already started
		dry_timer.start()
		return
	
	# Watering amount was reached
	watering_completed.emit()
	
	if grow_seed == null:
		# Start dry timer if not already started
		dry_timer.start()
		return
	
	if not plant:
		# Grow plant
		_spawn_plant()
	
	dry_timer.stop()

func _spawn_plant_no_seed(plant_name: String) -> Plant:
	# Spawn plant
	ResourceSingleton.instance.get_resource(plant_name)
	plant = ResourceSingleton.instance.get_resource(plant_name).instantiate()
	add_child(plant)
	plant.position = Vector3.ZERO
	
	# Update Lookup
	DigSpotLookup.add(self, plant)
	return plant

func _spawn_plant():
	# Spawn plant
	plant = ResourceSingleton.instance.get_resource(grow_seed.plant).instantiate()
	
	plant.position = Vector3.ZERO
	add_child(plant)
	
	# Remove grow_seed
	var tween : Tween = create_tween()
	tween.tween_property(grow_seed, "scale", Vector3(0.001, 0.001, 0.001), 0.5)
	tween.tween_callback(grow_seed.queue_free)
	
	# Update Lookup
	DigSpotLookup.add(self, plant)

func _reparent_seed_callback():
	grow_seed.get_parent().remove_child(grow_seed)
	seed_snap_point.add_child(grow_seed)
	
	# Reset position to ZERO because of the reparenting
	grow_seed.position = Vector3.ZERO

func play_jiggle(strength : float = 0.1, length : float = 0.2):
	if jiggle_tween and jiggle_tween.is_running():
		jiggle_tween.kill()
	
	# Play jiggle animation for dig spot
	jiggle_tween = create_tween()
	jiggle_tween.tween_property(self, "scale", Vector3(1.0 - strength, 1.0 - strength, 1.0 - strength), length)
	jiggle_tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), length)

func _on_trigger_body_exited(_body):
	hand = null
	time = 0.0
	
	# Lerp progress to zero
	var tween = create_tween()
	tween.tween_property(self, "progress", 0, 0.2)

func reset_watering(new_watering_amount : int):
	# Reset to dry state
	play_jiggle(0.05)
	material_changer.set_state_by_index(0)
	
	# Reset watering amount and set new value
	watering_amount = new_watering_amount
	current_water = 0

func set_outline(visibility : bool):
	# Tween alpha of outline
	var tween : Tween = create_tween()
	if visibility:
		tween.tween_method(_set_shader_parameter, 0.0, 1.0, 0.5)
	else:
		tween.tween_method(_set_shader_parameter, 1.0, 0.0, 0.5)
	
	#outline_mesh.visible = visibility

func _set_shader_parameter(value : float) -> void:
	outline_mesh.set_instance_shader_parameter("alpha", value)
