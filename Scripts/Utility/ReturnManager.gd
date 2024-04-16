@icon("res://Textures/EditorIcons/ReturnManager.png")
@tool
class_name ReturnManager
extends Area3D

@export var group_name : String = "Returnable"
@export var debug_draw : bool

@export_category("Enable States")
@export var enable_area_reset : bool = true
@export var enable_range_reset : bool = true

@export_category("Range Reset")
@export var range : float = 1.0
@export var range_origin : Vector3

var reset_transforms = {}

var _returning_objects = []

func _process(_delta):
	# Draw debug lines if in editor
	if debug_draw and Engine.is_editor_hint():
		DebugDraw3D.draw_sphere(range_origin, range)
	
	if enable_range_reset and not Engine.is_editor_hint():
		for node in reset_transforms:
			var distance : float = node.global_position.distance_to(reset_transforms[node].origin)
			
			if distance < range:
				continue
			
			# Check if already returning
			if node in _returning_objects:
				continue
			_returning_objects.append(node)
			
			# Tween scale / Animation
			var tween : Tween = create_tween()
			tween.tween_property(node, "scale", Vector3(0.1, 0.1, 0.1), 0.1)
			tween.tween_callback(Callable(_restore_transform).bind(node))

func _on_body_entered(body : RigidBody3D):
	if not enable_area_reset:
		return
	
	if not body.is_in_group(group_name):
		return
	
	# Check if already returning
	if body in _returning_objects:
		return
	_returning_objects.append(body)
	
	# Tween scale / Animation
	var tween : Tween = create_tween()
	tween.tween_property(body, "scale", Vector3(0.1, 0.1, 0.1), 0.1)
	tween.tween_callback(Callable(_restore_transform).bind(body))

func _restore_transform(node : RigidBody3D):
	# Wait time until transform restore
	node.visible = false
	await get_tree().create_timer(1.0).timeout
	node.visible = true
	
	# Remove object from returning list
	_returning_objects.erase(node)
	
	# Reset velocity of body
	node.linear_velocity = Vector3.ZERO
	node.angular_velocity = Vector3.ZERO
	
	# Reset transform (Position, Rotation)
	node.transform = reset_transforms[node]
	
	# Appear tween
	var old_scale : Vector3 = node.scale
	node.scale = Vector3(0.1, 0.1, 0.1)
	
	var appear_tween : Tween = create_tween()
	appear_tween.tween_property(node, "scale", old_scale, 0.1)

func _get_data():
	# Find all object in group "returnable"
	var returnables : Array[Node] = get_tree().get_nodes_in_group(group_name)
	
	# Save object positions into dictonary for later usage
	for node in returnables:
		if not node.is_queued_for_deletion():
			reset_transforms[node] = node.transform

func update(clear_old : bool = true):
	if clear_old:
		# Clear all position
		reset_transforms.clear()
		
		# Fill with new data
		_get_data()
	else:
		# Find all object in group "returnable"
		var returnables : Array[Node] = get_tree().get_nodes_in_group(group_name)
		
		# Remove old nodes
		for node in reset_transforms:
			if not returnables.has(node):
				reset_transforms.erase(node)
		
		# Add new nodes
		for node in returnables:
			if not reset_transforms.has(node):
				reset_transforms[node] = node.transform





