@icon("res://Textures/EditorIcons/Fertilizer.png")
class_name PotionEvent
extends PlantEvent

@export var particles_position : Vector3 = Vector3(0.0, 0.0, 0.0)
@export var falling_leaf_particles : PackedScene

var icon_overrides : Array[Texture2D] = [
	preload("res://Textures/EventIcons/PotionRed.png"),
	preload("res://Textures/EventIcons/PotionGreen.png"),
	preload("res://Textures/EventIcons/PotionOrange.png"),
	preload("res://Textures/EventIcons/PotionBlue.png"),
	preload("res://Textures/EventIcons/PotionPurple.png"),
	preload("res://Textures/EventIcons/PotionCyan.png"),
	preload("res://Textures/EventIcons/PotionGrey.png"),
]

var requested_potion_type : Potion.TYPE
var digspot : DigSpot
var plant_material : ShaderMaterial

var _particle_instance : ParticleCombiner

func initialize():
	# Get plants digspot
	digspot = DigSpotLookup.get_dig_spot(self.owner)
	
	# Connect potion added event
	digspot.potion_added.connect(_potion_added)
	
	# Active digspot outline
	digspot.set_outline(true)
	
	# Decide on request potion type
	if GameBase.level.enable_brewing:
		requested_potion_type = randi_range(1, Potion.TYPE.size() - 1) # Get random potion from "all" potions
	else:
		requested_potion_type = [Potion.TYPE.RED, Potion.TYPE.GREEN, Potion.TYPE.BLUE].pick_random() # Get random potion from "base" potions
	
	# Override icon texture
	icon_texture = icon_overrides[requested_potion_type - 1]
	
	# Gather plant material
	plant_material = owner.get_node("Model").get_child(0).get_surface_override_material(0)
	
	# Tween material
	var mat_tween : Tween = create_tween()
	mat_tween.tween_method(_set_shader_parameter, 1.0, 0.6, 2.0)
	
	# Start emitting leaf particles
	_particle_instance = falling_leaf_particles.instantiate()
	add_child(_particle_instance)
	
	# Set correct particles position
	_particle_instance.position = particles_position

func cleanup():
	digspot.potion_added.disconnect(_potion_added)

func _potion_added(type : Potion.TYPE) -> void:
	# Check for correct type
	if not type == requested_potion_type:
		return
	
	# Jiggle plant
	digspot.play_jiggle(0.1, 0.2)
	
	# Disable digspot outline
	digspot.set_outline(false)
	
	# Tween material back to normal
	var mat_tween : Tween = create_tween()
	mat_tween.tween_method(_set_shader_parameter, 0.6, 1.0, 2.0)
	
	# Complete event
	event_completed.emit()
	
	# Stop emitting leaf particles
	_particle_instance.stop()
	
	await get_tree().create_timer(_particle_instance.get_max_lifetime()).timeout
	
	# Free particle system
	_particle_instance.queue_free()

func _set_shader_parameter(value : float) -> void:
	plant_material.set_shader_parameter("albedo", Color(value, value, value))
