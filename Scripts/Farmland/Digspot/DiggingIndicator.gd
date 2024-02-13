@icon("res://Textures/Indicator.png")
class_name Indicator
extends Area3D

@export var allowed_material : Color
@export var restricted_material : Color

@onready var indicator_halo : MeshInstance3D = $"Indicator Halo"

var ignore_lerp : bool = true
var state : STATE

var indicator_material : ShaderMaterial

enum STATE
{
	HIDDEN,
	RESTRICTED,
	ALLOWED
}

func _ready():
	# Set default state to hidden
	set_state(STATE.HIDDEN)
	
	indicator_material = indicator_halo.get_surface_override_material(0)

func set_state(new_state : STATE):
	state = new_state
	
	# Set visiblity on indicator
	if state == STATE.HIDDEN:
		indicator_halo.visible = false
	if state == STATE.RESTRICTED:
		indicator_halo.visible = true
		indicator_material.set_shader_parameter("base_color", restricted_material)
	if state == STATE.ALLOWED:
		indicator_halo.visible = true
		indicator_material.set_shader_parameter("base_color", allowed_material)
