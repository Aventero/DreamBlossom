@icon("res://Textures/EditorIcons/DigSpot.png")
class_name DigSpot
extends Node3D

signal watering_completed

signal fertilizer_added(type : Fertilizer.Type)

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
@onready var outline_mesh : MeshInstance3D = $Outline

var anchor_cell : GridCell
var cell_width : int

# Removing function
var progress : float
var hand : XRToolsCollisionHand
var previous_hand_position : Vector3

# Seed / Plant
var seed : Seed = null
var plant : Node3D = null

# Watering
var current_water : int = 0

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
		remove_self()

func remove_self():
	# Free occupied cells in grid
	anchor_cell.grid.set_state(anchor_cell, cell_width, false)
	
	# Spawn remove particles
	var particles : GPUParticles3D = remove_particles.instantiate()
	add_child(particles)
	particles.position = Vector3(0, 0.2, 0)
	particles.emitting = true
	
	# Start remove animation
	var remove_tween = create_tween()
	remove_tween.tween_property(self, "global_position", global_position + Vector3(0, -0.2, 0), 2.0)
	remove_tween.tween_callback(Callable(_free_callback))
	
	# Update Lookup
	DigSpotLookup.remove(self)
	
	to_be_deleted = true

func _free_callback():
	queue_free()

func _on_trigger_body_entered(body):
	# Check if body is hand
	if hand_removal and body is XRToolsCollisionHand:
		_handle_hand_movement(body)
	
	# Check if body is seed
	if seed_insertion and not seed and body is Seed and body.planted == false:
		# Ensure that seed is only planted once
		seed = body
		seed.planted = true
		
		_handle_seed_insert()
	
	# Check if body is waterdrop
	if watering and body is WaterDrop and current_water < watering_amount:
		_handle_water_drop()
	
	# Check if body is fertilizer
	if fertilizing and body is Fertilizer and fertilizer_added.get_connections().size() > 0:
		# Play jiggle
		_play_jiggle()
		
		# Despawn fertilizer
		body.drop()
		body.queue_free()
		
		# Emit fertilizer signal
		fertilizer_added.emit(body.type)

func _handle_hand_movement(body : Node3D):
	# Check if hand is currently holding a object
	var function_pickup : XRToolsFunctionPickup = body.get_node("FunctionPickup")
	
	if not function_pickup or function_pickup.picked_up_object:
		return
	
	# Save current hand
	hand = body
	previous_hand_position = body.global_position

func _handle_seed_insert():
	# Force player to drop seed
	seed.drop()
	
	# Disable pickable from seed
	seed.enabled = false
	seed.freeze = true
	
	# Disable inactivity manager
	for child in seed.get_children():
		if child is InactivityManager:
			child.queue_free()
	
	# Stop watering timer
	dry_timer.stop()
	
	# Reset rotation and place seed to snap point
	var tween : Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(seed, "rotation", Vector3.ZERO, 0.05)
	tween.tween_property(seed, "global_position", seed_snap_point.global_position, 0.05)
	
	# Play jiggle animation for dig spot
	_play_jiggle()
	
	# Spawn particles
	var particles : GPUParticles3D = seed_insert_particles.instantiate()
	add_child(particles)
	particles.position = seed_snap_point.position + Vector3(0, 0.1, 0)
	particles.emitting = true
	
	# Reparent seed after tween
	tween.tween_callback(Callable(_reparent_seed_callback))
	
	# Spawn plant if water is enough
	if current_water >= watering_amount:
		_spawn_plant()

func _handle_water_drop():
	# Added a drop of water
	current_water += 1
	
	# Change material to next state
	_play_jiggle(0.05)
	material_changer.next_state()
	
	# Check if fully watered
	if current_water != watering_amount:
		# Start dry timer if not already started
		dry_timer.start()
		return
	
	# Watering amount was reached
	watering_completed.emit()
	
	if seed == null:
		# Start dry timer if not already started
		dry_timer.start()
		return
	
	if not plant:
		# Grow plant
		_spawn_plant()
	
	dry_timer.stop()

func _spawn_plant():
	# Spawn plant
	plant = ResourceSingleton.instance.get_resource(seed.plant).instantiate()
	plant.position = Vector3.ZERO
	add_child(plant)
	
	# Remove seed
	var tween : Tween = create_tween()
	tween.tween_property(seed, "scale", Vector3.ZERO, 0.5)
	
	# Update Lookup
	DigSpotLookup.add(self, plant)

func _reparent_seed_callback():
	seed.get_parent().remove_child(seed)
	seed_snap_point.add_child(seed)
	
	# Reset position to ZERO because of the reparenting
	seed.position = Vector3.ZERO

func _play_jiggle(strength : float = 0.1):
	# Play jiggle animation for dig spot
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.0 - strength, 1.0 - strength, 1.0 - strength), 0.05)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.05)

func _on_trigger_body_exited(body):
	hand = null
	time = 0.0
	
	# Lerp progress to zero
	var tween = create_tween()
	tween.tween_property(self, "progress", 0, 0.2)

func reset_watering(new_watering_amount : int):
	# Reset to dry state
	_play_jiggle(0.05)
	material_changer.set_state_by_index(0)
	
	# Reset watering amount and set new value
	watering_amount = new_watering_amount
	current_water = 0

func set_outline(visibility : bool):
	outline_mesh.visible = visibility
