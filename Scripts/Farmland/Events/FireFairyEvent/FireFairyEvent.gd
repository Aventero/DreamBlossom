@icon("res://Textures/EditorIcons/FireFairyEvent.png")
class_name FireFairyEvent
extends PlantEvent

@export var fire : PackedScene
@export var fairy_spawns : Array[FairySpawn]

var _fire_amount : int = 0
var _fire_extinguished : int = 0

func initialize():
	for spawn in fairy_spawns:
		spawn.show_fairy()
	
	# for each spawnpoint spawn fire
	for child in get_children():
		if not child.is_in_group("Spawnpoint"):
			return
		_fire_amount += 1
		
		var fire_instance = fire.instantiate()
		child.add_child(fire_instance)
		
		fire_instance.scale = Vector3.ZERO
		fire_instance.fire_fairy_event = self
		
		# Appear squish
		var tween : Tween = create_tween()
		tween.tween_property(fire_instance, "scale", Vector3(0.9, 1.5, 0.9), 0.2)
		tween.tween_property(fire_instance, "scale", Vector3(1.3, 0.8, 1.3), 0.1)
		tween.tween_property(fire_instance, "scale", Vector3.ONE, 0.1)
		
		await get_tree().create_timer(randf_range(0.1, 0.5)).timeout

func fire_extinguished():
	_fire_extinguished += 1
	
	if _fire_extinguished >= _fire_amount:
		for spawn in fairy_spawns:
			spawn.hide_fairy()
		
		event_completed.emit()
