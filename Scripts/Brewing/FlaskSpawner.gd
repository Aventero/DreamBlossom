class_name FlaskSpawner
extends Node3D

@export var flask : PackedScene
@export var inactivity_manager : PackedScene

@onready var spawnpoint : Node3D = $Spawnpoint

func _ready() -> void:
	# Spawn first flask on start
	_spawn_flask()

func _spawn_flask() -> void:
	# Instantiate flask
	var empty_potion : Potion = flask.instantiate()
	empty_potion.position = Vector3(0.0, -0.108, 0.0)
	spawnpoint.add_child(empty_potion)
	empty_potion.freeze = true
	
	# Connect pickup event
	empty_potion.picked_up.connect(_flask_picked_up)
	

func _flask_picked_up(pickable : XRToolsPickable) -> void:
	# Disconnect pickup event
	pickable.picked_up.disconnect(_flask_picked_up)
	
	# Reenable collision with player hand
	#pickable.set_collision_mask_value(18, true)
	#pickable.set_collision_mask_value(3, true)
	
	# Start timer
	$Timer.start()
	
	# Add empty potion to inactivity manager
	InactivityManager.get_instance().add_node(pickable, true)

func _on_timeout() -> void:
	print("3Node still in tree: ", is_inside_tree())
	_spawn_flask()
