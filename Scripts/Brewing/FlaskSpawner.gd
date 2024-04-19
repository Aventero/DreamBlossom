class_name FlaskSpawner
extends Node3D

@export var flask : PackedScene
@export var inactivity_manager : PackedScene

func _ready() -> void:
	# Spawn first flask on start
	_spawn_flask()

func _spawn_flask() -> void:
	# Instantiate flask
	var empty_potion : Potion = flask.instantiate()
	add_child(empty_potion)
	empty_potion.scale = Vector3(0.0001, 0.0001, 0.0001)
	
	# Lerp scale
	var tween : Tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(empty_potion, "scale", Vector3.ONE, 1.0)
	
	# Connect pickup event
	empty_potion.picked_up.connect(_flask_picked_up)
	
	# Disable collision with player hand
	empty_potion.set_collision_mask_value(18, false)
	empty_potion.set_collision_mask_value(3, false)
	
	# Freeze object
	empty_potion.freeze = true

func _flask_picked_up(pickable : XRToolsPickable) -> void:
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
	_spawn_flask()
