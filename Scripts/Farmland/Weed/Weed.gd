@icon("res://Textures/EditorIcons/WeedEvent.png")
class_name Weed
extends Pullable

signal removed(weed : Weed)

@export_range(0.0, 1.0, 0.01) var spread_chance : float 
var digspot : DigSpot
var cell : GridCell

var _spreading_jiggle : Tween
var _spreading_cell : GridCell
var _spreading_timer : SceneTreeTimer
var _skip_spreading : bool = false

func spread(jiggle_time : float) -> void:
	_skip_spreading = false
	
	# Get random free cell
	_spreading_cell = cell.grid.get_nearby_free_cell(cell)
	
	# No free cell
	if not _spreading_cell:
		return
	
	# Reserve weed spot
	WeedManager.get_instance().reserve_cell(_spreading_cell)
	
	# Connect state change event
	_spreading_cell.state_change.connect(_state_changed)
	
	# Set timer
	_spreading_timer = get_tree().create_timer(jiggle_time)
	
	# Start jiggle tween
	_play_jiggle()
	
	# Wait for spreading jiggle to be done
	await _spreading_timer.timeout
	_spreading_timer = null
	
	if _spreading_jiggle:
		_spreading_jiggle.kill()
		_spreading_jiggle = null
	
	if not _spreading_cell:
		return
	
	# Disconnect from cell event
	_spreading_cell.state_change.disconnect(_state_changed)
	
	# Block spreading if player is holding the weed
	if is_picked_up() or _skip_spreading:
		# Free reserved cell
		WeedManager.get_instance().free_cell(_spreading_cell)
		_spreading_cell = null
		return
	
	# Spawn new weed
	WeedManager.get_instance().spawn_weed(_spreading_cell)
	_spreading_cell = null

func _state_changed(state):
	print(state)
	if not state == GridCell.CELLSTATE.OCCUPIED:
		return
	
	if _spreading_jiggle:
		_spreading_jiggle.kill()
		_spreading_jiggle = null
	
	# Tween back to normal
	var abort_tween : Tween = create_tween()
	abort_tween.tween_property(self, "scale", Vector3.ONE, 0.2)
	
	# Disconnect from cell event
	_spreading_cell.state_change.disconnect(_state_changed)
	_spreading_cell = null

func _play_jiggle() -> void:
	if not _spreading_timer:
		return
	
	await WeedManager.get_instance().jiggle_synchronisation
	
	_spreading_jiggle = create_tween().set_loops()
	_spreading_jiggle.tween_property(self, "scale", Vector3(1.1, 1.1, 1.1), 0.2)
	_spreading_jiggle.tween_property(self, "scale", Vector3.ONE, 0.2)

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
	
	WeedManager.get_instance().spawn_weed(random_cell)

func _on_pull_pickup_picked_up(pickable):
	# Kill spreading jiggle
	if _spreading_jiggle:
		_spreading_jiggle.kill()
		_spreading_jiggle = null
	
	super(pickable)

func _on_pull_pickup_dropped(pickable):
	super(pickable)
	
	var tween : Tween = create_tween()
	tween.tween_property(digspot, "scale", Vector3.ONE, 0.1)
	
	# Resume spreading jiggle
	if _spreading_timer:
		if _spreading_timer.time_left > 1.0:
			_play_jiggle()
		else:
			_skip_spreading = true

func _on_pull_completed():
	# Free spreading cell
	if _spreading_cell:
		# Disconnect state change event
		_spreading_cell.state_change.disconnect(_state_changed)
		WeedManager.get_instance().free_cell(_spreading_cell)
		_spreading_cell = null
	
	removed.emit(self)
	
	# Remove digspot from grid
	_remove_from_grid()
	
	var tween : Tween = create_tween()
	tween.tween_property($Model, "scale", Vector3.ZERO, 0.1)

func _remove_from_grid():
	# Get current digspot
	if not digspot:
		digspot = DigSpotLookup.get_dig_spot(self)
	
	# Start remove animation
	var remove_tween : Tween = create_tween()
	remove_tween.tween_property(digspot, "global_position", global_position + Vector3(0, -0.2, 0), 1.0)
	remove_tween.tween_callback(digspot.queue_free)

func _on_grab():
	if not digspot:
		digspot = DigSpotLookup.get_dig_spot(self)
	
	_grab_tween = create_tween()
	_grab_tween.tween_property(digspot, "scale", Vector3(0.9, 0.9, 0.9), 0.05)
