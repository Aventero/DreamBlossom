@icon("res://Textures/EditorIcons/WeedManager.png")
class_name WeedManager
extends Node3D

signal jiggle_synchronisation

@export var plot : Node3D

@export_category("Spawn Chances")
@export_range(0, 1.0, 0.01) var inital_weed_chance : float
@export_range(0, 1.0, 0.01) var additional_weed_chance : float

@export_category("Spread Chances")
@export var spread_time : float = 0.0
@export var spread_indicator_time : float = 0.0
@export_range(0.0, 1.0, 0.01) var spread_chance : float = 0.0

@export_category("References")
@export var weed : PackedScene
@export var grow_particles : PackedScene

@onready var spread_timer : Timer = $SpreadTimer

var soil : PlantGrid
var weed_instances : Array[Weed]

static var instance : WeedManager

func _ready():
	# Setup Singelton
	if instance == null:
		instance = self
	else:
		queue_free()
	
	# Find soil in plot object
	for child in plot.get_children():
		if child.is_in_group("Soil"):
			soil = child
			break

static func get_instance() -> WeedManager:
	return instance

func _on_grow_timer_timeout() -> void:
	# Calculate current chance for weed spawn
	var chance : float = additional_weed_chance
	
	if soil.current_weed_amount == 0.0:
		chance = inital_weed_chance
	
	# Check if new weed is spawning
	if randf() < chance:
		# Get random free cell
		var free_cells : Array[GridCell] = soil.get_free_cells()
		
		if free_cells.size() <= 0:
			return
		
		# Select random cell
		var random_cell : GridCell = free_cells[randi_range(0, free_cells.size() - 1)]
		spawn_weed(random_cell)

func _on_spread_timer_timeout() -> void:
	var spread_amount : int = 0
	
	# Check for each weed if weed is spreading
	for weed_instance in weed_instances:
		if randf() > spread_chance:
			continue
		
		# Skip hold weed
		if weed_instance.is_picked_up():
			continue
		
		# Start spread process for weed
		weed_instance.spread(spread_indicator_time)
		spread_amount += 1
	
	# Wait for jiggle / spread to complete
	if spread_amount > 0:
		# Start jiggle synchronisation
		var sync : Tween = create_tween().set_loops()
		sync.tween_interval(0.4)
		sync.tween_callback(func(): jiggle_synchronisation.emit())
		
		# Wait for spreading to complete
		await get_tree().create_timer(spread_indicator_time).timeout
		
		sync.kill()
		sync = null
	
	# Restart spread timer
	spread_timer.start(spread_time)

func free_cell(cell : GridCell):
	soil.set_state(cell, 1, GridCell.CELLSTATE.FREE)

func reserve_cell(cell : GridCell):
	soil.set_state(cell, 1, GridCell.CELLSTATE.RESERVED)

func spawn_weed(cell : GridCell, ignore_particles : bool = false):
	# Occupy space on soil
	soil.set_state(cell, 1, GridCell.CELLSTATE.OCCUPIED)
	soil.current_weed_amount += 1
	
	# Spawn new weed
	var weed_digspot = weed.instantiate()
	soil.add_sibling(weed_digspot)
	weed_digspot.global_position = soil.get_placement_position(cell, 1)
	weed_digspot.scale = Vector3(0.0, 0.0, 0.0)
	
	# Spawn grow particles
	if not ignore_particles:
		var grow_parts : GPUParticles3D = grow_particles.instantiate()
		add_child(grow_parts)
		
		# Move particles to correct position and rotation
		grow_parts.global_position = weed_digspot.global_position + Vector3(0, 0.2, 0)
		grow_parts.global_rotation = Vector3.UP
		grow_parts.emitting = true
	
	# Get weed reference
	var weed_instance : Weed = weed_digspot.get_child(0)
	weed_instances.append(weed_instance)
	
	# Connect removal event
	weed_instance.removed.connect(_on_weed_removed)
	
	# Set data in weed plant
	weed_instance.cell = cell
	DigSpotLookup.add(weed_digspot, weed_instance)
	
	# Tween scale back to normal
	var tween : Tween = create_tween()
	tween.tween_property(weed_digspot, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

func _on_weed_removed(weed : Weed):
	# Free occupied space on soil
	soil.set_state(weed.cell, 1, GridCell.CELLSTATE.FREE)
	soil.current_weed_amount -= 1
	
	# Remove weed from weed instances
	weed_instances.erase(weed)
	
	print("New weeds: ", weed_instances)

func setup_soil_arrangement(soil_setup : String):
	var setup_array : PackedStringArray = soil_setup.split(",")
	var index : int = 0
	
	# Spawn inital objects
	for cell in setup_array:
		match cell:
			"W": spawn_weed(soil.get_cell_by_index(index), true)
		
		index += 1
