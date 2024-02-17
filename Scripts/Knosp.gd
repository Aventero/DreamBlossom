@icon("res://Textures/LeafPullEvent.png")
class_name Knosp
extends Pullable

@onready var outline_mesh : MeshInstance3D = $Model/Outline
@onready var knosp_closed : Node3D = $"Model/Knosp Closed"
@onready var knosp_open : Node3D = $"Model/Knosp Open"

var knosp_event : KnospEvent
var _inital_scale : Vector3

func set_event(event : KnospEvent):
	knosp_event = event
	knosp_event.owner.dying.connect(remove_on_plant_die)

func _on_pull_pickup_picked_up(pickable):
	super(pickable)
	
	# Disable outline
	outline_mesh.visible = false

func _on_pull_pickup_dropped(pickable):
	super(pickable)
	
	# Enable outline
	outline_mesh.visible = true

func _on_xr_tools_highlight_visible_visibility_change(visible):
	if picked_by:
		return
	
	outline_mesh.visible = !visible

func _on_pull_completed():
	outline_mesh.queue_free()
	
	# Change model
	knosp_closed.visible = false
	knosp_open.visible = true
	
	knosp_event.knosp_open()

func _pull_animation(ratio):
	model.rotation = Vector3(
		0,
		sin(time * 20) * ratio * 0.1,
		cos(time * 20) * ratio * 0.1
	)

func remove_on_plant_die():
	var removal : Tween = create_tween()
	removal.tween_property(self, "scale", Vector3.ZERO, 0.2)
	removal.tween_callback(queue_free)
