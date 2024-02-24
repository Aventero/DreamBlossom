@icon("res://Textures/IceCube.png")
class_name IceFairyEvent
extends PlantEvent

@export var ice_cube : PackedScene
@export var min_cube_hits : int = 2
@export var max_cube_hits : int = 5

var _ice_cube_amount : int
var _destroyed_cubes : int = 0

func initialize():
	_ice_cube_amount = get_child_count()
	
	# for each spawnpoint spawn icecube
	for child in get_children():
		var ice_cube_instance = ice_cube.instantiate()
		child.add_child(ice_cube_instance)
		
		ice_cube_instance.scale = Vector3.ZERO
		ice_cube_instance.ice_fairy_event = self
		ice_cube_instance.hits_required = randi_range(min_cube_hits, max_cube_hits)
		
		var tween : Tween = create_tween()
		tween.tween_property(ice_cube_instance, "scale", Vector3.ONE, 0.25)
		
		await get_tree().create_timer(randf_range(0.1, 1.0)).timeout

func cleanup():
	pass

func ice_cube_destroyed():
	_destroyed_cubes += 1
	
	if _destroyed_cubes >= _ice_cube_amount:
		event_completed.emit()
