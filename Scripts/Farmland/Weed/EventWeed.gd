@icon("res://Textures/EditorIcons/WeedEvent.png")
class_name EventWeed
extends Pullable

@onready var outline_mesh : MeshInstance3D = $Model/Outline

var weed_event : WeedEvent = null

func _on_pull_pickup_picked_up(pickable):
	super(pickable)

	# Disable outline
	outline_mesh.visible = false

func _on_pull_pickup_dropped(pickable):
	super(pickable)
	
	# Enable outline
	outline_mesh.visible = true

func _on_pull_completed():
	weed_event.pulled_weed()
	outline_mesh.queue_free()
	
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(queue_free)

func _on_xr_tools_highlight_visible_visibility_change(_visible):
	if picked_by:
		return
	
	outline_mesh.visible = !_visible
