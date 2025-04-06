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
	if weed_event:
		weed_event.pulled_weed()
		
	visible = false
	
	#var tween = create_tween()
	#tween.tween_property(self, "scale", Vector3(0.001, 0.001, 0.001), 0.3)
	#tween.tween_callback(Callable(_hide_weed))
