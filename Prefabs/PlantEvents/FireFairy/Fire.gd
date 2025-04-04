@icon("res://Textures/EditorIcons/FireFairyEvent.png")
class_name Fire
extends Node3D

@export var disappear_particles : Array[GPUParticles3D]

@onready var water_trigger : CollisionShape3D = $Trigger/Shape
@onready var particle_combiner : ParticleCombiner = $Particles

var fire_fairy_event : FireFairyEvent
var extinguished : bool = false

func _on_trigger_body_entered(_body: Node3D) -> void:
	if extinguished:
		return
		
	extinguished = true
	
	# Defer disabling the trigger to avoid physics errors
	call_deferred("_disable_water_trigger")
	
	# Stop particles
	particle_combiner.stop()
	
	# Disappear tween
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.5)
	
	play_smoke()
	
	if fire_fairy_event:
		fire_fairy_event.fire_extinguished()
	
	# Wait for particles to finish
	await get_tree().create_timer(particle_combiner.get_max_lifetime()).timeout
	queue_free()

# This function will be called after physics processing is complete
func _disable_water_trigger() -> void:
	water_trigger.disabled = true

func play_smoke() -> void:
	# Disappear particles
	for parts in disappear_particles:
		#parts.emitting = true
		parts.restart()
