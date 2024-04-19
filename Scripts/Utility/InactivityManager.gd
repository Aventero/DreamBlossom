@icon("res://Textures/EditorIcons/Cog.png")
class_name InactivityManager
extends Node3D

# Singelton instance
static var instance : InactivityManager

@export var default_inactivity_time : float = 10.0

var _observed_nodes : Dictionary = { }

func _ready() -> void:
	# Setup singleton
	if instance == null:
		instance = self
	else:
		queue_free()

func _process(delta: float) -> void:
	for node in _observed_nodes.keys():
		# Skip currently hold nodes
		if _observed_nodes[node]["picked_up"]:
			continue
		
		# Reduce time
		_observed_nodes[node]["inactivity_time"] -= delta
		
		if _observed_nodes[node]["inactivity_time"] <= 0.0:
			_despawn_node(node)

func add_node(node : Node3D, currently_hold : bool = false) -> void:
	# Skip if node is already observed
	if _observed_nodes.has(node):
		return
	
	# Add node to observed list
	_observed_nodes[node] = {
		"inactivity_time" : default_inactivity_time,
		"picked_up" : currently_hold
	}
	
	# Add pickup event if pickable
	if node is XRToolsPickable:
		node.picked_up.connect(_on_node_pickup)
		node.dropped.connect(_on_node_dropped)

func remove_node(node : Node3D) -> void:
	# Do nothing if node is currently not observed
	if not _observed_nodes.has(node):
		return
	
	_observed_nodes.erase(node)
	
	# Disconnect event if node was pickable
	if node is XRToolsPickable:
		node.picked_up.disconnect(_on_node_pickup)
		node.dropped.disconnect(_on_node_dropped)

func _on_node_pickup(pickable : XRToolsPickable) -> void:
	# Reset inactivity timer
	_observed_nodes[pickable]["picked_up"] = true

func _on_node_dropped(pickable : XRToolsPickable) -> void:
	# Reset inactivity timer
	_observed_nodes[pickable]["inactivity_time"] = default_inactivity_time
	_observed_nodes[pickable]["picked_up"] = false

func _despawn_node(node : Node3D) -> void:
	# Disable pickup if pickable
	if node is XRToolsPickable:
		node.drop()
		node.enabled = false
	
	# Remove from observed list
	remove_node(node)
	
	# Tween scale to zero
	var tween : Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_property(node, "scale", Vector3.ZERO, 0.5)
	
	# Free node after tween finished
	await tween.finished
	node.queue_free()

static func get_instance() -> InactivityManager:
	return instance
