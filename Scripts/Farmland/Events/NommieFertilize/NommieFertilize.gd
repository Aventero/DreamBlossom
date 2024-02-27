@icon("res://Textures/Fertilizer.png")
class_name NommieFertilize
extends Area3D

var _event : NommieFertilizeEvent
var _accept_food : bool = false

func setup(event : NommieFertilizeEvent) -> void:
	_event = event
	
	# Open mouth
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property($"../Model/Lower_Head", "rotation", Vector3(0.296706, 0, 0), 0.5)
	tween.tween_property($"../Model/Upper_Head", "rotation", Vector3(-1.239184, 0, 0), 0.5)
	
	# Enable trigger
	monitorable = true
	monitoring = true
	
	_accept_food = true

func _on_body_entered(body: Node3D) -> void:
	if not _accept_food:
		return
	_accept_food = false
	
	if not body is Fertilizer:
		return
	
	# Correct Fertilizer
	if body.type == _event.target_fertilizer_type:
		# Despawn fertilizer
		body.drop()
		body.freeze = true
		body.enabled = false
		
		var fertilizer_tween : Tween = create_tween()
		fertilizer_tween.tween_property(body, "scale", Vector3.ZERO, 0.2)
		fertilizer_tween.tween_callback(body.queue_free)
		
		# Wait for eating animation to finish
		await _play_eat().finished
		
		# Reset mouth to default position
		var mouth_tween : Tween = create_tween().set_parallel(true)
		mouth_tween.tween_property($"../Model/Lower_Head", "rotation", Vector3(0.122173, 0, 0), 0.5)
		mouth_tween.tween_property($"../Model/Upper_Head", "rotation", Vector3(-0.8866273, 0, 0), 0.5)
		
		# Notify event
		_event.fertilizer_added()
		
		_cleanup()
	# Wrong Fertilizer
	else:
		# Disable outline while nommie is shaking his head
		owner.set_outline(false)
		
		# Shake Head
		await _play_shake().finished
		
		owner.set_outline(true)
	
	_accept_food = true

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

func _play_shake():
	var tween : Tween = create_tween().set_loops(3)
	
	tween.tween_property($"../Model", "rotation", Vector3(0, 0.1570796, 0), 0.075)
	tween.tween_property($"../Model", "rotation", Vector3(0, 0, 0), 0.075)
	tween.tween_property($"../Model", "rotation", Vector3(0, -0.1570796, 0), 0.075)
	tween.tween_property($"../Model", "rotation", Vector3(0, 0, 0), 0.075)
	
	return tween

func _cleanup() -> void:
	# Disable parent outline
	owner.set_outline(false)
	
	# Disable trigger
	monitorable = false
	monitoring = false
	
	# Reset event reference
	_event = null
