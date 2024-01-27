@icon("res://Textures/WeedEvent.png")
class_name EventWeed
extends Weed

@onready var weed_event : WeedEvent = $"../.."

func _ready():
	super()

func _process(delta):
	super(delta)

func _on_pull_completed():
	weed_event.pulled_weed.emit()
	super()

func _on_pull_pickup_dropped(pickable):
	super(pickable)

func _on_pull_pickup_picked_up(pickable):
	# Squish on first pickup
	_grab_squish()
	
	# Add pull rumble haptic to correct controller
	var controller : XRController3D = pickable.get_picked_up_by_controller()
	XRToolsRumbleManager.add("pull_rumble", pull_rumble, [controller])
	
func _grab_squish():
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", initial_scale * 0.9, 0.05)
