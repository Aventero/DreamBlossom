@icon("res://Textures/EditorIcons/Fairy.png")
@tool
class_name FairySpawn
extends Node3D

@export var radius : float = 0.5
@export var movement_speed : float = 1.0
@export var max_vertical_movement : float = 0.1
@export var vertical_movement_frequency : float = 1.0 
@export var fairy : PackedScene

@export var debug_draw : bool = false

var _fairy_instance
var _angle : float = 0

func _ready():
	if not Engine.is_editor_hint():
		set_process(false)

func _process(delta):
	# Handle debug circle draw
	if Engine.is_editor_hint() and debug_draw:
		DebugDraw3D.draw_cylinder_ab(position - Vector3(0, max_vertical_movement / 2, 0), position + Vector3(0, max_vertical_movement / 2, 0), radius / 2)
	
	_angle += movement_speed * delta
	
	# Calculate new position of fairy
	var new_x = cos(_angle) * radius
	var new_z = sin(_angle) * radius
	var new_y = sin(_angle * vertical_movement_frequency) * max_vertical_movement
	
	$Fairy.position = Vector3(new_x, new_y, new_z)
	$Fairy.rotation = Vector3(0, -_angle, 0)

func show_fairy():
	set_process(true)
	
	_fairy_instance = fairy.instantiate()
	$Fairy.add_child(_fairy_instance)
	
	# Tween size
	_fairy_instance.scale = Vector3.ZERO
	
	var tween : Tween = create_tween()
	tween.tween_property(_fairy_instance, "scale", Vector3.ONE, 1.0)

func hide_fairy():
	# Tween size
	var tween : Tween = create_tween()
	tween.tween_property(_fairy_instance, "scale", Vector3(0.001, 0.001, 0.001,), 1.0)
	tween.tween_callback(_fairy_instance.queue_free)
	tween.tween_callback(func(): set_process(false))
