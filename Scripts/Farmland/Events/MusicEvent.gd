@icon("res://Textures/MusicBox.png")
class_name MusicEvent
extends PlantEvent

@export var target_time : float = 2.0

var current_time : float = 0.0
var dig_spot : DigSpot
var inital_scale : Vector3

var plant_tween : Tween

func _ready():
	inital_scale = owner.get_node("Model").scale
	
	# Disable processing until event is called
	set_process(false)

func initialize():
	# Get current digspot for later
	dig_spot = DigSpotLookup.get_dig_spot(self.owner)
	
	# Enable processing (_process function)
	set_process(true)

func _process(delta):
	# Check if in affected range
	if MusicBox.is_affected(dig_spot):
		_music_jiggle()
		
		current_time += delta
	else:
		current_time = 0.0
	
	# Check if target music amount is reached
	if current_time >= target_time:
		event_completed.emit()

func _music_jiggle():
	# Skip jiggle if currently jiggling
	if plant_tween:
		return
	
	# Request new tween from plant
	plant_tween = owner.request_tween()
	
	if plant_tween:
		# Single jiggle tween
		plant_tween.tween_property(owner.get_node("Model"), "scale", inital_scale + Vector3(0.0, 0.1, 0.0), 0.25)
		plant_tween.tween_property(owner.get_node("Model"), "scale", inital_scale + Vector3(0.0, -0.1, 0.0), 0.15)
		plant_tween.tween_property(owner.get_node("Model"), "scale", inital_scale, 0.1)
		plant_tween.tween_callback(Callable(_reset_tween))

func _reset_tween():
	plant_tween = null

func cleanup():
	# Disable processing again
	set_process(false)
