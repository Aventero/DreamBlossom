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
	if bad_shroomie_event:
		bad_shroomie_event.shroomie_removed()
	visible = false
