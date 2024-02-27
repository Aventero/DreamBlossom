@icon("res://Textures/EditorIcons/BadShroomieEvent.png")
class_name BadShroomie
extends Pullable

@onready var outline_mesh : MeshInstance3D = $Model/Outline

var bad_shroomie_event : BadShroomieEvent = null

func _on_pull_pickup_picked_up(pickable):
	super(pickable)

	# Disable outline
	outline_mesh.visible = false

func _on_pull_pickup_dropped(pickable):
	super(pickable)
	
	# Enable outline
	outline_mesh.visible = true

func _on_pull_completed():
	bad_shroomie_event.shroomie_removed()
	outline_mesh.queue_free()
	
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.1)
	tween.tween_callback(queue_free)

func _on_xr_tools_highlight_visible_visibility_change(visible):
	if picked_by:
		return
	
	outline_mesh.visible = !visible
