@icon("res://Textures/MusicBox.png")
class_name MusicBox
extends XRToolsPickable

@onready var range_indicator : MeshInstance3D = $Range
@onready var note_particles : GPUParticles3D = $NoteParticles

static var turned_on : bool = false
static var _affected_digspots : Dictionary

func _process(delta):
	if turned_on:
		# Correct rotation
		range_indicator.global_rotation = Vector3.ZERO
		note_particles.global_rotation = Vector3.ZERO

func _on_action_pressed(pickable):
	turned_on = !turned_on
	range_indicator.visible = turned_on
	
	if turned_on:
		# Start emitting notes
		note_particles.emitting = true
		
		# Start jiggle animation
		_play_jiggle()
	else:
		# Stop emitting notes
		note_particles.emitting = false
		
		# Clear affected areas
		_affected_digspots.clear()

func _play_jiggle():
	var tween : Tween = create_tween()
	
	# Stop jiggle if turned off
	if not turned_on:
		tween.tween_property($MusicBox, "scale", Vector3(1, 1, 1), 0.2)
		return
	
	# Jiggle Tween
	tween.tween_property($MusicBox, "scale", Vector3(1, 1.2, 1), 0.2)
	tween.tween_property($MusicBox, "scale", Vector3(1.2, 0.8, 1.2), 0.2)
	tween.tween_callback(Callable(_play_jiggle))

func _on_range_area_area_entered(area):
	var digspot : DigSpot = area.get_parent()
	
	if not digspot in _affected_digspots:
		_affected_digspots[digspot] = null

func _on_range_area_area_exited(area):
	var digspot : DigSpot = area.get_parent()
	
	if digspot in _affected_digspots:
		_affected_digspots.erase(digspot)

static func is_affected(digspot : DigSpot) -> bool:
	if not turned_on:
		return false
	
	return digspot in _affected_digspots
