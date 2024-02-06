@icon("res://Textures/Koriko.png")
class_name Koriko
extends XRToolsPickable

var manager : KorikoManager

var _tween : Tween
var _is_fed : bool = false

func _ready():
	super()
	
	_play_jiggle()

func _on_feed_area_body_entered(body):
	# Check if body is ingredient
	if not body is Ingredient or _is_fed:
		return
	
	_is_fed = true
	
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
	_play_vanish()

func _play_jiggle():
	_tween = create_tween().set_loops()
	_tween.tween_property($Model, "scale", Vector3(1, 1.05, 1), 1.0)
	_tween.tween_property($Model, "scale", Vector3(1.05, 0.95, 1.05), 1.0)

func _play_eating():
	_tween = create_tween().set_loops(3)
	_tween.tween_property($Model/Mouth, "scale", Vector3(0.8, 1.2, 1), 0.2)
	_tween.tween_property($Model/Mouth, "scale", Vector3(1.2, 0.8, 1), 0.2)

func _play_vanish():
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

func _on_picked_up(pickable):
	pass # Replace with function body.

func _on_dropped(pickable):
	if _is_fed:
		return
	
	manager.spawn_smoke(global_position)
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.1, 0.1, 0.1), 0.5)
	freeze = true
	
	await tween.finished
	
	visible = false
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	
	await get_tree().create_timer(1.0).timeout
	manager.spawn_smoke(global_position)
	await get_tree().create_timer(0.1).timeout
	
	visible = true
	tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, 0.5)
