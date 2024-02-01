@icon("res://Textures/WateringCan.png")
class_name WateringCan
extends XRToolsPickable

@export var water_drop : PackedScene
@export var checks_per_second : int
@export var water_angle : float

@onready var water_particles : GPUParticles3D = $"Water Particles"

var angle : float
var interval : float
var time : float = 0.0
var velocity_strength : float

func _ready():
	super()
	
	# Calculate time between collision checks
	interval = 1.0 / checks_per_second
	
	# Calculate average velocity of particles
	velocity_strength = (water_particles.process_material.initial_velocity_min + water_particles.process_material.initial_velocity_max) / 2.0

func _process(delta):
	time += delta
	
	# Calculate current angle of can based on shaft <=> Vector Up
	angle = rad_to_deg((-water_particles.global_transform.basis.z).angle_to(Vector3.UP))
	
	# Depending on angle emit water particles
	if angle > water_angle:
		water_particles.emitting = true
	
		# Check if interval is due
		if not time >= interval:
			return
		time = 0.0
		
		# Spawn invisible water drops for collision detection
		var water_drop : RigidBody3D = water_drop.instantiate()
		
		# Add drop not as child so watering can movement dont interfer with falling curve
		add_sibling(water_drop)
		
		water_drop.global_position = water_particles.global_position
		water_drop.linear_velocity = -water_particles.global_transform.basis.z * velocity_strength
	else:
		water_particles.emitting = false
