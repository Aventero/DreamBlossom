class_name ResolutionButton
extends XRToolsInteractableAreaButton

func _on_button_pressed(button: Variant) -> void:
	var current_scale: float = get_3d_scale()
	if current_scale <= 0.25:
		return
	current_scale -= 0.05
	adjust_3d_scale(current_scale)

func adjust_3d_scale(scale_value: float):
	ProjectSettings.set_setting("rendering/scaling_3d/scale", scale_value)
	ProjectSettings.save()

	# For VR, you might need to trigger an XR interface update
	var xr = XRServer.get_primary_interface()
	if xr:
		# This might help force a refresh of the VR rendering
		xr.set_render_target_size_multiplier(scale_value)

func get_3d_scale() -> float:
	return ProjectSettings.get_setting("rendering/scaling_3d/scale")
