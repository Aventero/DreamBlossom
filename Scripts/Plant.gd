extends Node3D

@onready var spawnpoint_parent : Node3D = $Spawnpoints
@onready var grow_timer : Timer = $GrowTimer
@onready var fruit : PackedScene = preload("res://Prefabs/DefaultFruit.tscn")
@onready var grown_fruits : Node3D = $GrownFruits

var spawnpoints : Array[SpawnPoint]

func _ready() -> void:
	# Get all spawnpoints
	var num_children = spawnpoint_parent.get_child_count()
	
	for i in range(num_children):
		var spawn : SpawnPoint = SpawnPoint.new(spawnpoint_parent.get_child(i).global_position)
		spawnpoints.append(spawn)
	
	# Spawn first row of fruits
	_on_grow_timer()
	
	# Start grow timer
	grow_timer.start()


func _on_grow_timer() -> void:
	# Spawn new fruits
	for i in range(spawnpoints.size()):
		if spawnpoints[i].has_grown == false:
			var fruit_instance : Node3D = fruit.instantiate()
			
			# Setup fruit
			fruit_instance.freeze = true
			fruit_instance.name = fruit_instance.name + "_spawnpoint_" + str(i)
			fruit_instance.global_position = spawnpoint_parent.to_local(spawnpoints[i].spawn_position)
			
			grown_fruits.add_child(fruit_instance)
			
			# Connect pick up signal for reparenting
			fruit_instance.picked_up.connect(_on_fruit_pickup.bind(spawnpoints[i]))
			
			spawnpoints[i].has_grown = true


func _on_fruit_pickup(_pickable, spawnpoint : SpawnPoint) -> void:
	spawnpoint.has_grown = false


# This class hold the current state of a spawnpoint
class SpawnPoint:
	var spawn_position : Vector3
	var has_grown : bool
	
	func _init(spawn_position : Vector3):
		self.spawn_position = spawn_position
		self.has_grown = false
