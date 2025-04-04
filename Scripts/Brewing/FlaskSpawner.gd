class_name FlaskSpawner
extends Node3D

@export var flask : PackedScene
@export var inactivity_manager : PackedScene

@onready var spawnpoint : Node3D = $Spawnpoint

func _ready() -> void:
	# Spawn first flask on start
	_spawn_flask()

func _spawn_flask() -> void:
	spawnpoint.scale = Vector3(0.0001, 0.0001, 0.0001)
	#spawnpoint.scale = Vector3(1, 1, 1)
	
	# Instantiate flask
	var empty_potion : Potion = flask.instantiate()
	empty_potion.position = Vector3(0.0, -0.108, 0.0)
	spawnpoint.add_child(empty_potion)
	
	# Lerp scale
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(spawnpoint, "scale", Vector3.ONE, 1.0)
	
	# Connect pickup event
	empty_potion.picked_up.connect(_flask_picked_up)
	
	# Disable collision with player hand
	#empty_potion.set_collision_mask_value(18, false)
	#empty_potion.set_collision_mask_value(3, false)
	
	# Freeze object
	empty_potion.freeze = true

	# Disable object while scaling
	empty_potion.enabled = false
	await tween.finished

	empty_potion.reparent(self)
	empty_potion.enabled = true

func _flask_picked_up(pickable : XRToolsPickable) -> void:
	pickable.freeze = false
	
	# Disconnect pickup event
	pickable.picked_up.disconnect(_flask_picked_up)
	
	# Reenable collision with player hand
	pickable.set_collision_mask_value(18, true)
	pickable.set_collision_mask_value(3, true)
	
	# Start timer
	$Timer.start()
	
	# Add empty potion to inactivity manager
	InactivityManager.get_instance().add_node(pickable, true)

func _on_timeout() -> void:
	print("3Node still in tree: ", is_inside_tree())
	_spawn_flask()
