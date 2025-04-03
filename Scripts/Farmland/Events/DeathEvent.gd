@icon("res://Textures/EditorIcons/DeathEvent.png")
class_name DeathEvent
extends PlantEvent

@export var plant_model : Node3D
@export var death_material : Material

@onready var animation_player = $"../../AnimationPlayer"

func initialize():
	# change material to the one thats exported 
	assign_material_to_all_meshes(plant_model, death_material)
	
	owner.emit_dying()
	
	# Quickly Play the animation backwards
	var _stage : Stage = get_parent_node_3d()
	animation_player.speed_scale = 10
	animation_player.play_backwards("Grow")

func assign_material_to_all_meshes(node : Node3D, material_to_assign : Material):
	# Set the material on each mesh
	for child in node.get_children():
		if child is MeshInstance3D:
			child.material_override = material_to_assign
		assign_material_to_all_meshes(child, material_to_assign)

func _on_animation_player_animation_finished(_anim_name):
	# Die once the animation is back at the start
	DigSpotLookup.get_dig_spot(self.owner).remove_self()
