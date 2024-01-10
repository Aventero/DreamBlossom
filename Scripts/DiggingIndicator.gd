@icon("res://Textures/Indicator.png")
class_name Indicator
extends Area3D

@onready var indicator_allowed : MeshInstance3D = $"Digging Spot Allowed"
@onready var indicator_restricted : MeshInstance3D = $"Digging Spot Restricted"

var ignore_lerp : bool = true
var state : STATE

enum STATE
{
	HIDDEN,
	RESTRICTED,
	ALLOWED
}

func _ready():
	# Set default state to hidden
	set_state(STATE.HIDDEN)

func set_state(new_state : STATE):
	state = new_state
	
	# Set visiblity on indicator
	if state == STATE.HIDDEN:
		indicator_allowed.visible = false
		indicator_restricted.visible = false
	if state == STATE.RESTRICTED:
		indicator_allowed.visible = false
		indicator_restricted.visible = true
	if state == STATE.ALLOWED:
		indicator_allowed.visible = true
		indicator_restricted.visible = false
