@icon("res://Textures/DigSpot.png")
class_name DigSpot
extends Node3D

@export var remove_amount : float
@export var max_jiggle : float
@export var max_jiggle_speed : float

@export var particles : PackedScene

var anchor_cell : GridCell
var cell_width : int

# Removing function
var progress : float
var hand : Node3D
var previous_hand_position : Vector3

var time : float = 0.0
var to_be_deleted : bool = false

func _process(delta):
	if to_be_deleted:
		return
	
	time += delta
	
	# Animate tile according to progress
	if (progress > 0.0):
		var ratio : float = progress / remove_amount
		
		var jiggle : float = sin(time * max_jiggle_speed) * max_jiggle * ratio
		
		rotation = Vector3(0, deg_to_rad(jiggle), 0)
	
	if not hand:
		return
	
	# Calc traveled distance
	var distance : float = hand.global_position.distance_to(previous_hand_position)
	previous_hand_position = hand.global_position
	
	progress += distance
	
	if progress > remove_amount:
		anchor_cell.grid.set_state(anchor_cell, cell_width, false)
		
		var parts : GPUParticles3D = particles.instantiate()
		add_child(parts)
		parts.position = Vector3(0, 0.2, 0)
		parts.emitting = true
		
		var remove_tween = create_tween()
		remove_tween.tween_property(self, "global_position", global_position + Vector3(0, -0.2, 0), 2.0)
		remove_tween.tween_callback(Callable(_free_callback))
		
		to_be_deleted = true

func _free_callback():
	queue_free()

func _on_trigger_body_entered(body):
	hand = body
	
	previous_hand_position = body.global_position

func _on_trigger_body_exited(body):
	hand = null
	
	var tween = create_tween()
	tween.tween_property(self, "progress", 0, 0.2)
	# progress = 0.0
