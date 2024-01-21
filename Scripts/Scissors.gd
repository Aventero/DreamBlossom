@icon("res://Textures/Scissors.png")
class_name Scissors
extends XRToolsPickable

@export var open_scissors : MeshInstance3D
@export var closed_scissors : MeshInstance3D
var inside_dead_leaf : DeadLeaf 

func _ready():
	super()

func _process(delta):
	pass

func _on_action_pressed(pickable : Scissors):
	open_scissors.hide()
	closed_scissors.show()
	_squish()	
	if inside_dead_leaf != null:
		inside_dead_leaf.prune()
		inside_dead_leaf = null

func _squish():
	# Get the mesh
	var initial_scale = self.scale
	var tween : Tween = create_tween()
	
	# Longate (increase length)
	var longated_scale = Vector3(initial_scale.x, initial_scale.y, initial_scale.z  * 1.25)
	tween.tween_property(self, "scale", longated_scale, 0.05)

	# Widen (increase width)
	var widened_scale = Vector3(initial_scale.x * 1.1, initial_scale.y, initial_scale.z)
	tween.tween_property(self, "scale", widened_scale, 0.025)

	# Return to normal
	tween.tween_property(self, "scale", initial_scale, 0.025)

func _on_action_released(pickable : Scissors):
	open_scissors.show()
	closed_scissors.hide()

func _on_dropped(pickable):
	open_scissors.show()
	closed_scissors.hide()

func _on_area_3d_area_entered(area : Area3D):
	inside_dead_leaf = area.get_parent_node_3d()
	
func _on_area_3d_area_exited(area):
	inside_dead_leaf = null



