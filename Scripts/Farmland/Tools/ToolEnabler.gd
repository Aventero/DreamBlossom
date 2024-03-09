@icon("res://Textures/EditorIcons/Cog.png")
class_name ToolsEnabler
extends Node3D

func load_tools_bags(active_mask) -> void:
	for i in get_child_count():
		if active_mask == null:
			get_child(i).queue_free()
			continue
		
		# Spawn in seed bag
		var mask = 1 << i
		if not active_mask & mask != 0:
			get_child(i).queue_free()
