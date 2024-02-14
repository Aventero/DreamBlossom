@icon("res://Textures/WeedEvent.png")
class_name Weed
extends Pullable

@export_range(0.0, 1.0, 0.01) var spread_chance : float 
var digspot : DigSpot
var cell : GridCell

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
	
	var tween : Tween = create_tween()
	tween.tween_property($Model, "scale", Vector3.ZERO, 0.1)

func _remove_from_grid():
	# Remove weed from soil logically
	WeedManager.get_instance().remove_weed(cell, cell.grid)
	
	# Get current digspot
	if not digspot:
		digspot = DigSpotLookup.get_dig_spot(self)
	
	# Start remove animation
	var remove_tween : Tween = create_tween()
	remove_tween.tween_property(digspot, "global_position", global_position + Vector3(0, -0.2, 0), 1.0)
	remove_tween.tween_callback(digspot.queue_free)

func _on_pull_pickup_dropped(pickable):
	super(pickable)
	
	var tween : Tween = create_tween()
	tween.tween_property(digspot, "scale", Vector3.ONE, 0.1)

func _on_grab():
	if not digspot:
		digspot = DigSpotLookup.get_dig_spot(self)
	
	_grab_tween = create_tween()
	_grab_tween.tween_property(digspot, "scale", Vector3(0.9, 0.9, 0.9), 0.05)
