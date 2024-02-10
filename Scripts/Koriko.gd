@icon("res://Textures/Koriko.png")
class_name Koriko
extends XRToolsPickable

@export var time_between_teleport : float = 1.0
@export var time_until_death : float = 1

var manager : KorikoManager
var angle_to_center : float

var _tween : Tween
var _is_fed : bool = false

func _ready():
	super()
	
	# Calculate angle to center
	angle_to_center = Vector3.BACK.signed_angle_to(Vector3(-global_position.x, 0.0, -global_position.z), Vector3.UP)
	global_rotation = Vector3(global_rotation.x, angle_to_center, global_rotation.z)
	
	# Start death timer
	get_tree().create_timer(time_until_death).timeout.connect(_on_death)
	
	_play_jiggle()

func _on_feed_area_body_entered(body):
	# Check if body is ingredient
	if not body is Ingredient or _is_fed:
		return
	
	_is_fed = true
	enabled = false
	
	# Despawn ingredient
	var ingredient : XRToolsPickable = body
	ingredient.drop()
	ingredient.queue_free()
	
	# Play eating animation
	_tween.kill()
	_play_eating()
	
	await _tween.finished
	
	# Drop Koriko
	drop()
	freeze = true
	enabled = false
	
	# Play vanish animation
	_play_fed_vanish()

func _on_dropped(pickable : RigidBody3D):
	if _is_fed:
		return
	
	_play_return_vanish()

func _on_death():
	print("[Koriko] You died!")

func _play_jiggle():
	_tween = create_tween().set_loops()
	_tween.tween_property($Model, "scale", Vector3(1, 1.05, 1), 1.0)
	_tween.tween_property($Model, "scale", Vector3(1.05, 0.95, 1.05), 1.0)

func _play_eating():
	_tween = create_tween().set_loops(3)
	_tween.tween_property($Model/Mouth, "scale", Vector3(0.8, 1.2, 1), 0.2)
	_tween.tween_property($Model/Mouth, "scale", Vector3(1.2, 0.8, 1), 0.2)

func _play_fed_vanish():
	_tween = create_tween().set_parallel(true)
	
	# Prepare jump
	_tween.tween_property($Model, "scale", Vector3(1.1, 0.7, 1.1), 0.2)
	_tween.tween_property(self, "global_rotation", Vector3(0.0, global_rotation.y, 0.0), 0.2)
	
	# Jump
	_tween.chain().tween_property($Model, "scale", Vector3(0.9, 1.2, 0.9), 0.2)
	_tween.tween_property(self, "position", position + Vector3(0, 0.2, 0), 0.1)
	
	# Scale down
	_tween.chain().tween_callback(func(): manager.spawn_smoke(global_position))
	_tween.tween_property(self, "scale", Vector3.ZERO, 0.1)

func _play_return_vanish():
	_tween = create_tween()
	
	# Spawn smoke
	manager.spawn_smoke(global_position)
	
	# Freeze so it stays where koriko was dropped
	freeze = true
	
	# Scale down to "vanish"
	_tween.tween_property(self, "scale", Vector3(0.1, 0.1, 0.1), 0.2)
	await _tween.finished
	
	# Reset position
	visible = false
	position = Vector3.ZERO
	global_rotation = Vector3(0.0, angle_to_center, 0.0)
	
	# Wait before reappearing
	await get_tree().create_timer(time_between_teleport).timeout
	
	# Spawn appearing smoke
	manager.spawn_smoke(global_position)
	await get_tree().create_timer(0.1).timeout
	
	visible = true
	
	# Scale back to inital state
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector3.ONE, 0.2)
