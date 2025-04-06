@icon("res://Textures/EditorIcons/IceCube.png")
class_name IceCube
extends Node3D

@export var velocity_threshold : float = 2.5
@export var hit_particles : PackedScene
@export var complete_particles : PackedScene

@onready var pickaxe_trigger : Area3D = $"Pickaxe Trigger"

var ice_fairy_event : IceFairyEvent
var hits_required : int = 1

var _total_hits : int = 0

func _on_pickaxe_trigger_body_entered(pickaxe_end):
	var pickaxe : Pickaxe = pickaxe_end.owner
	
	# Check if velocity of pickaxe is enough
	if pickaxe.linear_velocity.length() < velocity_threshold:
		return
	
	# Spawn hit particles
	var hit_particles_instance : ParticleCombiner = hit_particles.instantiate()
	add_child(hit_particles_instance)
	hit_particles_instance.global_position = pickaxe_end.global_position
	
	# Play jiggle
	var jiggle_tween : Tween = create_tween()
	jiggle_tween.tween_property($Model, "position", -hit_particles_instance.position.normalized() * 0.02, 0.05)
	jiggle_tween.tween_property($Model, "position", Vector3.ZERO, 0.05)
	
	_total_hits += 1
	
	if _total_hits >= hits_required:
		# Report destroyed cube
		ice_fairy_event.ice_cube_destroyed()
		pickaxe_trigger.queue_free()
		
		$"Ice Dust".emitting = false
		
		# Complete particles
		var complete_particles_instance : ParticleCombiner = complete_particles.instantiate()
		add_child(complete_particles_instance)
		
		# Hide cube
		var tween : Tween  = create_tween()
		tween.tween_property($Model, "scale", Vector3(0.001, 0.001, 0.001), 0.1)
		
		await complete_particles_instance.complete
		
		queue_free()
