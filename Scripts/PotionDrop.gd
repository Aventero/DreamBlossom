class_name PotionDrop
extends RigidBody3D

@export var type : Potion.TYPE = Potion.TYPE.RED
@export var splash_particles : PackedScene
@export var splash_decal : PackedScene
@export var drop_rumble : XRToolsRumbleEvent
var potion_holding_controller
var _contact_point : Vector3

func _on_body_entered(body: Node) -> void:
	splash_drop()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() >= 1:
		_contact_point = state.get_contact_local_position(0)

func splash_drop(override_position : Vector3 = Vector3.INF) -> void:
	# Destory collision to prevent further collisions
	$CollisionShape3D.queue_free()

	# Vanish drop
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.1)
	tween.tween_callback(queue_free)

	# Spawn splash particles
	var splash : ParticleCombiner = splash_particles.instantiate()
	add_sibling(splash)

	if override_position == Vector3.INF:
		splash.global_position = _contact_point
	else:
		splash.global_position = override_position

	# Decal
	var splash_decal : Node3D = splash_decal.instantiate()
	add_sibling(splash_decal)

	if !(potion_holding_controller == null):
		XRToolsRumbleManager.add("potion_drop", drop_rumble, potion_holding_controller)

	if override_position == Vector3.INF:
		splash_decal.global_position = _contact_point
	else:
		splash_decal.global_position = override_position

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
