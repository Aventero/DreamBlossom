@icon("res://Textures/LeafPullEvent.png")
class_name LeafPullPoint
extends Node3D

@export var pull_rumble : XRToolsRumbleEvent
@export var pulled_leaf : PullLeaf
@onready var pull_pickup : XRToolsPickable = $"Pull Origin/Pull Pickup"
@onready var pull_event : LeafPullEvent = $"../.."

@export_range(0, 1, 0.1) var target_pull_distance = 0.3
var _pull_tween : Tween

func _ready():
	pulled_leaf.visible = false

func _process(delta):
	if pull_pickup.is_picked_up():
		_handle_pull()
		
func _handle_pull():
	
	# player pulling on leaf 
	var distance_pulled : float = pull_pickup.position.length()
	var ratio_pulled : float = distance_pulled / target_pull_distance
	
	# controller rumble based on distance pulled
	pull_rumble.magnitude = ratio_pulled
	
	# Scale up the leaf by distance
	pulled_leaf.scale = Vector3(distance_pulled, distance_pulled, distance_pulled)
	
	# finish pulling once 100%
	if ratio_pulled >= 1.0:
		_pull_completed()

func _pull_completed():
	
	# Done pulling -> increase pull count
	pull_pickup.drop()
	pull_event.pulled_leaf.emit()
	XRToolsRumbleManager.clear("pull_rumble")
	pulled_leaf.visible = true
	
	# reparent to plant -> model
	var plant = get_parent().owner
	pulled_leaf.reparent(plant.get_node("Model"))
	pulled_leaf.reparented(plant)
	queue_free()
	
func _on_pull_pickup_picked_up(pickable):
	# Make ready for the pulling, make sure the retracting tween stops
	pulled_leaf.visible = true
	
	if _pull_tween:
		_pull_tween.kill()
	
	# Add pull rumble haptic to correct controller
	var controller : XRController3D = pickable.get_picked_up_by_controller()
	XRToolsRumbleManager.add("pull_rumble", pull_rumble, [controller])

func _on_pull_pickup_dropped(pickable):
	
	# Set pickup to origin position
	pull_pickup.position = Vector3.ZERO
	
	# Grow back the pulled leaf and hide it
	_pull_tween = create_tween()
	_pull_tween.tween_property(pulled_leaf, "scale", Vector3.ZERO, 0.25)
	pulled_leaf.visible = false
	XRToolsRumbleManager.clear("pull_rumble")
