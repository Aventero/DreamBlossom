@icon("res://Textures/EditorIcons/WeedEvent.png")
class_name Weed
extends Pullable

signal removed(weed : Weed)

# Weed data
var cell : GridCell

# Spreading data
var spreading_cell : GridCell
var spreading_blocked : bool

var _spreading_jiggle : Tween
var _digspot : DigSpot

func setup_spread(spread_cell : GridCell) -> void:
	# Set spreading cell
	spreading_cell = spread_cell
	
	# Reset data
	spreading_blocked = false
	
	# Connect state change event
	spreading_cell.state_change.connect(_state_changed)

func cleanup():
	if spreading_cell:
		if spreading_cell.state_change.has_connections():
			# Disconnect from cell event
			spreading_cell.state_change.disconnect(_state_changed)

func _state_changed(state):
	if not state == GridCell.CELLSTATE.OCCUPIED:
		return
	
	stop_jiggle()
	
	# Tween back to normal
	var abort_tween : Tween = create_tween()
	abort_tween.tween_property(self, "scale", Vector3.ONE, 0.2)
	
	# Disconnect from cell event
	spreading_cell.state_change.disconnect(_state_changed)
	
	spreading_blocked = true
	spreading_cell = null

func play_jiggle() -> void:
	await WeedManager.get_instance().jiggle_synchronisation
	
	_spreading_jiggle = create_tween().set_loops()
	_spreading_jiggle.tween_property(self, "scale", Vector3(1.1, 1.1, 1.1), 0.2)
	_spreading_jiggle.tween_property(self, "scale", Vector3.ONE, 0.2)

func stop_jiggle() -> void:
	# Kill spreading jiggle
	if _spreading_jiggle:
		_spreading_jiggle.kill()
		_spreading_jiggle = null

func _on_pull_pickup_picked_up(pickable):
	# Kill spreading jiggle
	if _spreading_jiggle:
		stop_jiggle()
	
	super(pickable)

func _on_pull_pickup_dropped(pickable):
	super(pickable)
	
	# Scale dispot back to normal size
	var tween : Tween = create_tween()
	tween.tween_property(_digspot, "scale", Vector3.ONE, 0.1)
	
	# Resume spreading jiggle
	if WeedManager.get_instance().is_spreading():
		if WeedManager.get_instance().get_remaining_spread_time() > WeedManager.get_instance().spread_release_grace_time and not spreading_blocked:
			play_jiggle()
		else:
			spreading_blocked = true

func _on_pull_completed():
	print("_on_pull_completed in WEED.tscn")
	
	# Free spreading cell
	cleanup()
	
	removed.emit(self)
	
	# Remove digspot from grid
	if not _digspot:
		_digspot = DigSpotLookup.get_dig_spot(self)
	
	# Start remove animation
	var remove_tween : Tween = create_tween()
	remove_tween.tween_property(_digspot, "global_position", global_position + Vector3(0, -0.2, 0), 1.0)
	remove_tween.tween_callback(_digspot.queue_free)
	
	var tween : Tween = create_tween()
	tween.tween_property($Model, "scale", Vector3(0.001, 0.001, 0.001), 0.1)

func _on_grab():
	if not _digspot:
		_digspot = DigSpotLookup.get_dig_spot(self)
	
	_grab_tween = create_tween()
	_grab_tween.tween_property(_digspot, "scale", Vector3(0.9, 0.9, 0.9), 0.05)
