@icon("res://Textures/EditorIcons/WeedManager.png")
class_name WeedManager
extends Node3D

@export var plots : Array[Node3D]

@export_category("Spawn Chances")
@export_range(0, 1.0, 0.01) var inital_weed_chance : float
@export_range(0, 1.0, 0.01) var additional_weed_chance : float

@export_category("References")
@export var weed : PackedScene
@export var grow_particles : PackedScene

var soils : Array[PlantGrid]

static var instance : WeedManager

func _ready():
	# Setup Singelton
	if instance == null:
		instance = self
	else:
		queue_free()
	
	# Get all plant grids of plots
	for plot in plots:
		for child in plot.get_children():
			if child.is_in_group("Soil"):
				soils.append(child)

static func get_instance() -> WeedManager:
	return instance

func _on_grow_timer_timeout():
	for soil in soils:
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
			spawn_weed(random_cell, soil)

func spawn_weed(cell : GridCell, grid : PlantGrid):
	# Spawn grow particles
	var grow_parts : GPUParticles3D = grow_particles.instantiate()
	add_child(grow_parts)
	
	# Occupy space on soil
	grid.set_state(cell, 1, true)
	grid.current_weed_amount += 1
	
	# Spawn new weed
	var weed_digspot = weed.instantiate()
	grid.add_sibling(weed_digspot)
	weed_digspot.global_position = grid.get_placement_position(cell, 1)
	weed_digspot.scale = Vector3(0.0, 0.0, 0.0)
	
	# Set data in weed plant (Must be first child!)
	weed_digspot.get_child(0).cell = cell
	DigSpotLookup.add(weed_digspot, weed_digspot.get_child(0))
	
	# Move particles to correct position and rotation
	grow_parts.global_position = weed_digspot.global_position + Vector3(0, 0.2, 0)
	grow_parts.global_rotation = Vector3.UP
	grow_parts.emitting = true
	
	# Tween scale back to normal
	var tween : Tween = create_tween()
	tween.tween_property(weed_digspot, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

func remove_weed(cell : GridCell, grid : PlantGrid):
	# Free occupied space on soil
	grid.set_state(cell, 1, false)
	grid.current_weed_amount -= 1
