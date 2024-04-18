class_name PotionDrop
extends RigidBody3D

@export var type : Potion.TYPE = Potion.TYPE.RED
@export var splash_particles : PackedScene
@export var splash_decal : PackedScene

var _contact_point : Vector3

func _on_body_entered(body: Node) -> void:
	splash_drop()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() >= 1:
		_contact_point = state.get_contact_local_position(0)

func splash_drop() -> void:
	# Destory collision to prevent further collisions
	$CollisionShape3D.queue_free()
	
	# Vanish drop
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.1)
	tween.tween_callback(queue_free)
	
	# Spawn splash particles
	var splash : ParticleCombiner = splash_particles.instantiate()
	add_sibling(splash)
	splash.global_position = _contact_point
	
	# Decal
	var splash_decal : Node3D = splash_decal.instantiate()
	add_sibling(splash_decal)
	splash_decal.global_position = _contact_point

func cauldron_splash(spawn_point : Vector3) -> void:
	# Destory collision to prevent further collisions
	$CollisionShape3D.queue_free()
	
	# Vanish drop
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.1)
	tween.tween_callback(queue_free)
	
	# Spawn splash particles
	var splash : ParticleCombiner = splash_particles.instantiate()
	add_sibling(splash)
	splash.global_position = spawn_point
