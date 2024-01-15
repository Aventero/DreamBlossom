extends Node3D

@onready var digging_spot : Node3D = $DirtHill
@onready var digging_spot_dug : Node3D = $DirtHillDug
@onready var seed_slot : Node3D = $DirtHillDug/Seed
@onready var timer : Custom_Timer = $GrowTimer
@onready var plant : PackedScene = preload("res://Prefabs/-- OLD --/Plant.tscn")

# Current state of digging spot
var state : DigSpotState

# Holds planted seed
var seed : XRToolsPickable = null

enum DigSpotState {
	UNTOUCHED,
	DUG,
	PLANTED,
	GROWN
}

func _ready():
	state = DigSpotState.UNTOUCHED

func _handle_presentation():
	if state == DigSpotState.UNTOUCHED:
		digging_spot.visible = true
		digging_spot_dug.visible = false
		timer.visible = false
	
	if state == DigSpotState.DUG:
		digging_spot.visible = false
		digging_spot_dug.visible = true
		timer.visible = false
	
	if state == DigSpotState.GROWN:
		digging_spot.visible = false
		digging_spot_dug.visible = false
		timer.visible = false


func _on_collision_body_entered(body : Node3D):
	# Check if entered object is held shovel
	if body.is_in_group("Shovel") and state == DigSpotState.UNTOUCHED:
		# Change state
		state = DigSpotState.DUG
		_handle_presentation()
	
	# Check if entered object is seed
	if body.is_in_group("Seed") and state == DigSpotState.DUG:
		seed = body as XRToolsPickable
		
		# Make sure that object is dropped
		seed.drop()
		
		# Change state
		state = DigSpotState.PLANTED
		
		# Disable pickable object and move it to seed spot
		seed.enabled = false
		seed.freeze = true
		seed.get_parent().remove_child(seed)
		seed_slot.add_child(seed)
		seed.position = Vector3.ZERO
		
		# Start grow timer
		timer.start_timer(30)
		timer.visible = true


func _on_grow_timer_timeout():
	state = DigSpotState.GROWN
	_handle_presentation()
	
	# Spawn plant
	var plant_instance : Node3D = plant.instantiate()
	add_child(plant_instance)
