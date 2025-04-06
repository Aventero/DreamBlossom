class_name NommieFeeding
extends Area3D

var _event : NommieFeedingEvent
var _accept_food : bool = false

func setup(event : NommieFeedingEvent) -> void:
	_event = event
	
	# Open mouth
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property($"../Model/Lower_Head", "rotation", Vector3(0.296706, 0, 0), 0.5)
	tween.tween_property($"../Model/Upper_Head", "rotation", Vector3(-1.239184, 0, 0), 0.5)
	
	_accept_food = true
	
	# Enable trigger
	get_child(0).disabled = false

func _on_body_entered(body: Node3D) -> void:
	if not _accept_food:
		return
	_accept_food = false
	
	if not body is Ingredient:
		return
	
	# Despawn fertilizer
	body.drop()
	body.freeze = true
	body.enabled = false
	
	var ingredient_tween : Tween = create_tween()
	ingredient_tween.tween_property(body, "scale", Vector3(0.001, 0.001, 0.001), 0.2)
	ingredient_tween.tween_callback(body.queue_free)
	
	# Wait for eating animation to finish
	await _play_eat().finished
	
	# Reset mouth to default position
	var mouth_tween : Tween = create_tween().set_parallel(true)
	mouth_tween.tween_property($"../Model/Lower_Head", "rotation", Vector3(0.122173, 0, 0), 0.5)
	mouth_tween.tween_property($"../Model/Upper_Head", "rotation", Vector3(-0.8866273, 0, 0), 0.5)
	
	# Notify event
	_event.feeding_complete()
	
	_cleanup()

func _play_eat() -> Tween:
	var tween : Tween = create_tween().set_parallel(true).set_loops(4)
	
	# Close mouth
	tween.tween_property($"../Model/Lower_Head", "rotation", Vector3.ZERO, 0.2)
	tween.tween_property($"../Model/Upper_Head", "rotation", Vector3(-0.7923795, 0, 0), 0.2)
	
	# Open mouth
	tween.chain().tween_interval(0.1)
	tween.tween_property($"../Model/Lower_Head", "rotation", Vector3(0.25, 0, 0), 0.2)
	tween.tween_property($"../Model/Upper_Head", "rotation", Vector3(-1.1, 0, 0), 0.2)
	
	return tween

func _cleanup() -> void:
	# Disable parent outline
	owner.set_outline(false)
	
	# Disable trigger
	get_child(0).disabled = true
	
	# Reset event reference
	_event = null
