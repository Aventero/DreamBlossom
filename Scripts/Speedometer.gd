extends Node3D

var prev_position : Vector3

@onready var debug_speed = $"../../Speedometer"
var speedmeter : Label

func _ready():
	speedmeter = debug_speed.get_node("Viewport/Panel/CenterContainer/Label")
	prev_position = global_position

func _process(delta):
	var current_position : Vector3 = global_position
	var delta_position : Vector3 = current_position - prev_position
	
	var velocity : Vector3 = delta_position / delta
	var speed : float = velocity.length()
	
	speedmeter.text = "%.2f" % speed
	
	prev_position = current_position
