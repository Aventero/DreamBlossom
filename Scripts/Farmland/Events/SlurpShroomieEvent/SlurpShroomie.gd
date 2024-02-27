@icon("res://Textures/EditorIcons/SlurpShroomieEvent.png")
class_name SlurpShroomie
extends Node3D

@export var fertilizer_colors : Array[Color]

@onready var fertilizer_particles : GPUParticles3D = $"Fertilizer Particles"
@onready var complete_particles : GPUParticles3D = $"Fertilizer Complete Particles"
@onready var central_force : GPUParticlesAttractorSphere3D = $"Center Force"
@onready var outline_mesh : MeshInstance3D = $Model/Outline

var slurp_event : SlurpShroomieEvent = null

var _requested_fertilizer : Fertilizer.Type
var _particle_material : StandardMaterial3D

func _ready():
	# Set random requested fertilizer
	_requested_fertilizer = randi_range(0, Fertilizer.Type.size() - 1)
	
	# Load particle material
	var _draw_pass_dup : Mesh = fertilizer_particles.draw_pass_1.duplicate()
	_particle_material = _draw_pass_dup.surface_get_material(0).duplicate()
	_draw_pass_dup.surface_set_material(0, _particle_material)
	fertilizer_particles.draw_pass_1 = _draw_pass_dup
	complete_particles.draw_pass_1 = _draw_pass_dup
	
	# Set requested fertilzer to random fertilizer
	_particle_material.albedo_color = fertilizer_colors[_requested_fertilizer]

func _on_fertilizer_trigger_body_entered(body : XRToolsPickable):
	if not body is Fertilizer:
		return
	
	body.drop()
	body.freeze = true
	body.enabled = false
	
	# Scale down and despawn fertilizer
	var vanish_tween : Tween = create_tween()
	vanish_tween.tween_property(body, "scale", Vector3.ZERO, 0.1)
	vanish_tween.tween_callback(body.queue_free)
	
	if not body.type == _requested_fertilizer:
		# Play squish
		var tween : Tween = create_tween()
		tween.tween_property($Model, "scale", Vector3(1.1, 1.1, 1.1), 0.1)
		tween.tween_property($Model, "scale", Vector3.ONE, 0.1)
	else:
		# Play vanish
		var tween : Tween = create_tween()
		tween.tween_property($Model, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
		tween.tween_property($Model, "scale", Vector3.ZERO, 0.2)
		
		# Disable outline
		outline_mesh.visible = false
		
		# Disable particles
		fertilizer_particles.emitting = false
		complete_particles.emitting = true
		
		# Invert force for an "explosion" effect
		central_force.strength *= -1.
		
		await complete_particles.finished
		
		# Notify slurp event
		if slurp_event and is_instance_valid(slurp_event):
			slurp_event.shroomie_slurped()
		
		queue_free()
