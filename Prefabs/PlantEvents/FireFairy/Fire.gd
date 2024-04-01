@icon("res://Textures/EditorIcons/FireFairyEvent.png")
class_name Fire
extends Node3D

@export var disappear_particles : Array[GPUParticles3D]

@onready var water_trigger : CollisionShape3D = $Trigger/Shape
@onready var particle_combiner : ParticleCombiner = $Particles

var fire_fairy_event : FireFairyEvent

func _on_trigger_body_entered(body: Node3D) -> void:
	# Disable trigger
	water_trigger.disabled = true
	
	# Stop particles
	particle_combiner.stop()
	
	# Disappear tween
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.5)
	
	# Disappear particles
	for parts in disappear_particles:
		parts.emitting = true
	
	if fire_fairy_event:
		fire_fairy_event.fire_extinguished()
	
	# Wait for particles to finish
	await particle_combiner.complete
	queue_free()
