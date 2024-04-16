@icon("res://Textures/EditorIcons/Scissors.png")
class_name Scissors
extends XRToolsPickable

@export var open_scissors : MeshInstance3D
@export var closed_scissors : MeshInstance3D

var inside_dead_leaf : Array[DeadLeaf] 

func _on_action_pressed(_pickable : Scissors):
	open_scissors.hide()
	closed_scissors.show()
	
	_squish()
	
	if inside_dead_leaf != null:
		for leaf in inside_dead_leaf:
			leaf.prune()
		inside_dead_leaf.clear()

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

func _on_action_released(_pickable : Scissors):
	open_scissors.show()
	closed_scissors.hide()

func _on_dropped(_pickable):
	open_scissors.show()
	closed_scissors.hide()

func _on_area_3d_area_entered(area : Area3D):
	var leaf = area.get_parent_node_3d()
	
	if not inside_dead_leaf.has(leaf):
		inside_dead_leaf.append(leaf)

func _on_area_3d_area_exited(area):
	var leaf = area.get_parent_node_3d()
	
	if inside_dead_leaf.has(leaf):
		inside_dead_leaf.erase(leaf)
