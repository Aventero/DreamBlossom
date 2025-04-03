@tool
class_name Candle
extends XRToolsPickable

@onready var fire : Fire = $Fire

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if not fire or fire.extinguished:
		return
	
	# Calculate angle to Y axis
	var angle : float = global_transform.basis.y.angle_to(Vector3.UP)
	
	# Rotate flame
	fire.global_rotation.x = 0.0
	fire.global_rotation.z = 0.0
	
	# Scale flame
	var new_scale = clamp(remap(angle, 0.785398, 1.919862, 1.0, 0.1), 0.1, 1.0)
	fire.scale = Vector3(new_scale, new_scale, new_scale)
	
	# Check if flame should be extinguished
	if angle > 1.919862:
		fire.extinguished = true
		
		# Hide fire model
		fire.get_node("Model").visible = false
		fire.scale = Vector3.ONE
		fire.rotation = Vector3.ZERO
		
		# Stop particles from spawning
		fire.get_node("Particles").stop()
		
		# Play smoke disappear particles
		fire.play_smoke()
		
		# Wait for particles to vanish and free
		await get_tree().create_timer(fire.get_node("Particles").get_max_lifetime()).timeout
		fire.queue_free()
