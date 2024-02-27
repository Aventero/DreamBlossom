@icon("res://Textures/EditorIcons/MaterialChanger.png")
class_name MaterialChanger
extends Node3D

@export var search_meshes_on_start : bool
@export var apply_state_on_start : bool

@export_category("Meshes")
@export var meshes : Array[MeshInstance3D]

@export_category("Material States")
@export var material_states : Array[MaterialState]

var current_state_index : int = 0

func _ready():
	if search_meshes_on_start:
		# Search all MeshInstance3D in parent und below
		findByClass(get_parent(), "MeshInstance3D")
	
	if apply_state_on_start and meshes.size() > 0:
		set_state_by_index(0)

func findByClass(node: Node, className : String):
	if node.is_class(className):
		meshes.push_back(node)
	
	for child in node.get_children():
		findByClass(child, className)

func set_state_by_index(index : int):
	# Check index
	if index < 0 or index >= material_states.size():
		return
	
	current_state_index = index
	
	# Get Material
	for mesh in meshes:
		if not is_instance_valid(mesh):
			continue
		
		mesh.set_surface_override_material(0, material_states[index].material)

func set_state_by_name(name : String):
	# Check if material of name exists
	for material_state in material_states:
		if material_state.name == name:
			var index : int = material_states.find(material_state)
			set_state_by_index(index)

func next_state():
	set_state_by_index(current_state_index + 1)

func previous_state():
	set_state_by_index(current_state_index - 1)
