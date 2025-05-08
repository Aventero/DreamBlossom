@icon("res://Textures/EditorIcons/SlurpShroomieEvent.png")
class_name SlurpShroomie
extends Node3D

@onready var slurp_particles : GPUParticles3D = $"Potion Particles"
@onready var complete_particles : GPUParticles3D = $"Potion Complete Particles"
@onready var central_force : GPUParticlesAttractorSphere3D = $"Center Force"
@onready var outline_mesh : MeshInstance3D = $Model/Outline

var slurp_event : SlurpShroomieEvent = null

var requested_potion_type : Potion.TYPE
var _particle_material : StandardMaterial3D
#
#func _ready():
	## Decide on request potion type
	##if GameBase.level.enable_brewing:
		##var random_index = randi_range(1, Potion.TYPE.size() - 1)
		##requested_potion_type = Potion.TYPE.values()[random_index]
	##else:
	#
	## Load particle material
	#var _draw_pass_dup : Mesh = slurp_particles.draw_pass_1.duplicate()
	#_particle_material = _draw_pass_dup.surface_get_material(0).duplicate()
	#_draw_pass_dup.surface_set_material(0, _particle_material)
	#slurp_particles.draw_pass_1 = _draw_pass_dup
	#complete_particles.draw_pass_1 = _draw_pass_dup
	#
	## Set requested fertilzer to random fertilizer
	##_particle_material.albedo_color = Potion.get_potion_data(requested_potion_type, Potion.PROPERTIES.COLOR)

func load_materials() -> void:
	var _draw_pass_dup : Mesh = slurp_particles.draw_pass_1.duplicate()
	_particle_material = _draw_pass_dup.surface_get_material(0).duplicate()
	_draw_pass_dup.surface_set_material(0, _particle_material)
	slurp_particles.draw_pass_1 = _draw_pass_dup
	complete_particles.draw_pass_1 = _draw_pass_dup

func _on_potion_trigger_body_entered(body : Variant):
	if not body is PotionDrop:
		return
	
	# Splash drop
	body.splash_drop(global_position)
	
	if not body.type == requested_potion_type:
		# Play squish
		var tween : Tween = create_tween()
		tween.tween_property($Model, "scale", Vector3(1.1, 1.1, 1.1), 0.1)
		tween.tween_property($Model, "scale", Vector3.ONE, 0.1)
	else:
		# Play vanish
		var tween : Tween = create_tween()
		tween.tween_property($Model, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
		tween.tween_property($Model, "scale", Vector3(0.001, 0.001, 0.001), 0.2)
		
		# Disable outline
		outline_mesh.visible = false
		
		# Disable particles
		slurp_particles.emitting = false
		complete_particles.emitting = true
		
		# Invert force for an "explosion" effect
		central_force.strength *= -1.
		
		await complete_particles.finished
		
		# Notify slurp event
		if slurp_event and is_instance_valid(slurp_event):
			slurp_event.shroomie_slurped()
		
		queue_free()
