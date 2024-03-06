@icon("res://Textures/EditorIcons/Cog.png")
class_name LevelActivationManager
extends Node3D

@export var objects : Array[String] = []

# Depending on given mask > Spawn specific objects
func load_objects(active_mask):
	for i in get_child_count():
		print("[Loading] Object #", i)
		if active_mask == null:
			continue
		
		# Spawn in seed bag
		var mask = 1 << i
		if active_mask & mask != 0:
			var object = ResourceSingleton.instance.get_resource(objects[i])
			
			if object:
				get_child(i).add_child(object.instantiate())
