@icon("res://Textures/Cog.png")
class_name KorikoManager
extends Timer

@export var time_before_first_spawn : float = 10.0
@export var inital_spawn_chance : float = 0.1
@export var stack_spawn_chance : float = 0.05

@onready var koriko : PackedScene = preload("res://Prefabs/Koriko.tscn")
@onready var smoke : PackedScene = preload("res://Prefabs/Smoke.tscn")

var _current_spawn_chance : float
var _korikos_to_spawn : int = 0

var _spawnpoints : Array[VisibleOnScreenNotifier3D]

func _ready():
	_current_spawn_chance = inital_spawn_chance
	
	# Get spawnpoints
	for spawnpoint in get_children():
		if not spawnpoint is VisibleOnScreenNotifier3D:
			continue
		
		_spawnpoints.append(spawnpoint)
	
	# Connect timeout
	timeout.connect(_on_spawn_timer_timeout)
	
	# Start graceful timer at start
	get_tree().create_timer(time_before_first_spawn).timeout.connect(start)

func _process(delta):
	# Do nothing if no korikos need to be spawned
	if _korikos_to_spawn == 0:
		return
	_korikos_to_spawn -= 1
	
	# Find free spawnpoint without an koriko
	for spawnpoint in _spawnpoints:
		# Check if currently visible
		if spawnpoint.is_on_screen():
			continue
		
		# Check if spawnpoint already has koriko
		if spawnpoint.get_child_count() > 0:
			continue
		
		# Found spawnpoint
		_spawn_koriko(spawnpoint)
		return

func _spawn_koriko(spawnpoint : Node3D):
	var koriko_instance = koriko.instantiate()
	spawnpoint.add_child(koriko_instance)
	
	spawn_smoke(spawnpoint.global_position)
	
	koriko_instance.manager = self

func _on_spawn_timer_timeout():
	var rnd_number : float = randf()
	
	# Check Koriko spawn
	if rnd_number < _current_spawn_chance:
		_korikos_to_spawn += 1
		_current_spawn_chance = inital_spawn_chance
	else:
		_current_spawn_chance += stack_spawn_chance

func spawn_smoke(position : Vector3):
	var smoke_instance : GPUParticles3D = smoke.instantiate()
	add_child(smoke_instance)
	smoke_instance.global_position = position