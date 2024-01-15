class_name WeedSpot
extends Node3D

@export_range(0.0, 1.0, 0.01) var spread_chance : float 

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
