@icon("res://Textures/WeedEvent.png")
class_name DigSpotWeed
extends Weed

@export_range(0.0, 1.0, 0.01) var spread_chance : float 
var digspot : DigSpot
var cell : GridCell

func _ready():
	super()
	initial_scale = get_parent().scale

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
	
	WeedManager.get_instance().spawn_weed(random_cell, random_cell.grid)

func _on_pull_completed():
	_remove_from_grid()
	super()

func _remove_from_grid():
	print("_remove_from_grid")
	# Remove weed from soil logically
	WeedManager.get_instance().remove_weed(cell, cell.grid)
	
	# Get current digspot
	if not digspot:
		print("looking up digspot")
		digspot = DigSpotLookup.get_dig_spot(self)
	
	# Start remove animation
	var remove_tween = create_tween()
	remove_tween.tween_property(digspot, "global_position", global_position + Vector3(0, -0.2, 0), 1.0)
	remove_tween.tween_callback(Callable(_free_callback))
	
func _free_callback():
	digspot.queue_free()

func _on_pull_pickup_dropped(pickable):
	var tween : Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(weed, "scale", Vector3.ONE, 0.1)
	tween.tween_property(digspot, "scale", initial_scale, 0.1)
	super(pickable)

func _on_pull_pickup_picked_up(pickable):
	# Squish on first pickup
	_grab_squish()
	
	# Add pull rumble haptic to correct controller
	var controller : XRController3D = pickable.get_picked_up_by_controller()
	XRToolsRumbleManager.add("pull_rumble", pull_rumble, [controller])
	
func _grab_squish():
	if not digspot:
		digspot = DigSpotLookup.get_dig_spot(self)
	
	var tween : Tween = create_tween()
	tween.tween_property(digspot, "scale", initial_scale * 0.9, 0.05)
