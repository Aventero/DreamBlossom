@icon("res://Textures/IceCube.png")
class_name IceFairyEvent
extends PlantEvent

@export var ice_cube : PackedScene
@export var min_cube_hits : int = 2
@export var max_cube_hits : int = 5
@export var fairy_spawns : Array[FairySpawn]
@export var appear_particles : PackedScene

var _ice_cube_amount : int = 0
var _destroyed_cubes : int = 0

func initialize():
	for spawn in fairy_spawns:
		spawn.show_fairy()
	
	# for each spawnpoint spawn icecube
	for child in get_children():
		if not child.is_in_group("Spawnpoint"):
			return
		_ice_cube_amount += 1
		
		var ice_cube_instance = ice_cube.instantiate()
		child.add_child(ice_cube_instance)
		
		ice_cube_instance.scale = Vector3.ZERO
		ice_cube_instance.ice_fairy_event = self
		ice_cube_instance.hits_required = randi_range(min_cube_hits, max_cube_hits)
		
		var tween : Tween = create_tween()
		tween.tween_property(ice_cube_instance, "scale", Vector3.ONE, 0.25)
		
		# Spawn appear particles
		var parts = appear_particles.instantiate()
		add_child(parts)
		parts.global_position = ice_cube_instance.global_position
		
		await get_tree().create_timer(randf_range(0.1, 0.5)).timeout

func cleanup():
	pass

func ice_cube_destroyed():
	_destroyed_cubes += 1
	
	if _destroyed_cubes >= _ice_cube_amount:
		for spawn in fairy_spawns:
			spawn.hide_fairy()
		
		event_completed.emit()
