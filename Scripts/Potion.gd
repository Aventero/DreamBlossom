@icon("res://Textures/EditorIcons/Potion.png")
@tool
class_name Potion
extends XRToolsPickable

@export_category("General")
@export var type : TYPE = TYPE.EMPTY:
	set(value):
		_type = value
		
		# Wait for single frame so all nodes are loaded
		await RenderingServer.frame_post_draw
		
		if _type != TYPE.EMPTY:
			# Set label data
			var label : Label3D = get_node("Indicator/PotionType")
			label.text = str(type)
			label.visible = true
			
			# Set fill color
			var potion_fill : MeshInstance3D = get_node("Model/Fill")
			potion_fill.set_surface_override_material(0, get_potion_data(value, PROPERTIES.FILL_MATERIAL))
			potion_fill.visible = true
			
			# Set hanging drop color
			var drop_material : StandardMaterial3D = get_node("Drop/Drop/Drop").get_surface_override_material(0).duplicate()
			drop_material.albedo_color = get_potion_data(value, PROPERTIES.COLOR)
			get_node("Drop/Drop/Drop").set_surface_override_material(0, drop_material)
		else:
			get_node("Indicator/PotionType").visible = false
			get_node("Model/Fill").visible = false
	get:
		return _type

@export_category("Pouring Settings")
@export var infinite_drops : bool = false
@export var tilt_angle : float 
@export var drop_fill_speed : float = 1.0
@export var max_drop_size : float = 8.0

@onready var drop_model : Node3D = $Drop/Drop
@onready var flask_stomp : Node3D = $Model/Stomp
@onready var flask_fill : MeshInstance3D = $Model/Fill

@onready var potion_type_label : Label3D = $Indicator/PotionType

var _max_drop_count : int
var _current_drop_count : int
var _drop_progress : float = 0.0
var _reduction_tween : Tween = null
var _stomp_tween : Tween = null
var _type : TYPE

enum TYPE {
	EMPTY,
	RED,
	GREEN,
	ORANGE,
	BLUE,
	PURPLE,
	CYAN,
	GREY
}

enum PROPERTIES {
	COLOR,
	DROP,
	FILL_MATERIAL
}

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# Do nothing if potion is currently empty
	if _type == TYPE.EMPTY:
		return
	
	# Update drop size
	if _drop_progress > 0.0:
		drop_model.visible = true
		drop_model.scale = Vector3.ONE * lerp(0.0, max_drop_size, _drop_progress)
	
	# Skip update if not currently hold
	if not is_picked_up():
		return
	
	# Limit drops
	if not infinite_drops and _current_drop_count <= 0:
		return
	
	var angle : float = transform.basis.y.angle_to(Vector3.UP)
	
	if rad_to_deg(angle) > 95:
		# Kill reduction tween if there is one
		if _reduction_tween:
			_reduction_tween.kill()
			_reduction_tween = null
		
		# Update progress
		_drop_progress += drop_fill_speed * delta
		
		if _drop_progress >= 1.0:
			# Reset drop progress
			_drop_progress = 0.0
			
			# Set hanging drop scale
			drop_model.visible = false
			drop_model.scale = Vector3(0.001, 0.001, 0.001)
			
			# Handle drop
			_handle_drop()
	else:
		# Start reduction tween
		if _reduction_tween and _reduction_tween.is_running():
			_reduction_tween.kill()
		
		_reduction_tween = create_tween()
		_reduction_tween.tween_property(self, "_drop_progress", 0.0, 0.1)
		_reduction_tween.tween_callback(func(): drop_model.scale = Vector3(0.001, 0.001, 0.001))
		_reduction_tween.tween_callback(func(): drop_model.visible = false)

func _handle_drop() -> void:
	var drop_instance : RigidBody3D = get_potion_data(_type, PROPERTIES.DROP).instantiate()
	get_parent().add_child(drop_instance)
	
	# Set position & rotation
	drop_instance.global_position = $Drop.global_position
	drop_instance.global_rotation = $Drop.global_rotation
	
	# Update fill shader
	if not infinite_drops:
		var old_fill_percentage : float = float(_current_drop_count) / float(_max_drop_count)
		var new_fill_percentage : float = float(_current_drop_count - 1) / float(_max_drop_count)
		
		var fill_tween : Tween = create_tween()
		fill_tween.tween_method(_lerp_fill, old_fill_percentage, new_fill_percentage, 0.2)
		
		# Reduce drop count
		_current_drop_count -= 1
		
		if _current_drop_count <= 0:
			fill_tween.tween_callback(_replace_with_empty).set_delay(0.1)

func _replace_with_empty() -> void:
	# Hide label
	await hide_type_label().finished
	
	# Set type to empty
	type = TYPE.EMPTY
	
	# Add self to Inactivity Manager
	InactivityManager.get_instance().add_node(self, is_picked_up())

func _lerp_fill(percentage : float):
	flask_fill.set_instance_shader_parameter("fill_percentage", percentage)

func _on_picked_up(pickable: Variant) -> void:
	# Despawn stomp
	if _stomp_tween and _stomp_tween.is_running():
		_stomp_tween.kill()
	_stomp_tween = create_tween()
	_stomp_tween.tween_property(flask_stomp, "scale", Vector3.ZERO, 0.1)

func _on_dropped(pickable: Variant) -> void:
	# Spawn stomp
	if _stomp_tween and _stomp_tween.is_running():
		_stomp_tween.kill()
	_stomp_tween = create_tween()
	_stomp_tween.tween_property(flask_stomp, "scale", Vector3(0.016, 0.016, 0.016), 0.1)
	
	# Start reduction tween
	if _reduction_tween and _reduction_tween.is_running():
		_reduction_tween.kill()
	
	_reduction_tween = create_tween()
	_reduction_tween.tween_property(self, "_drop_progress", 0.0, 0.1)
	_reduction_tween.tween_callback(func(): drop_model.scale = Vector3.ZERO)
	_reduction_tween.tween_callback(func(): drop_model.visible = false)

func show_type_label() -> Tween:
	var tween : Tween = create_tween()
	tween.tween_property(potion_type_label, "scale", Vector3(0.4, 0.4, 0.4), 0.25)
	return tween

func hide_type_label() -> Tween:
	var tween : Tween = create_tween()
	tween.tween_property(potion_type_label, "scale", Vector3.ZERO, 0.25)
	return tween

func fill_potion(p_type : TYPE, drops_per_potion : int) -> void:
	# Set type
	type = p_type
	
	# Reset / Fill drop count
	_max_drop_count = drops_per_potion
	_current_drop_count = drops_per_potion
	
	# Lerp potion fill level to max
	flask_fill.visible = true
	var fill_tween : Tween = create_tween()
	fill_tween.tween_method(_lerp_fill, 0.0, 1.0, 0.5)
	
	# Tween in type label
	potion_type_label.text = str(_type)
	show_type_label()
	
	# Remove self from inactivity manager
	InactivityManager.get_instance().remove_node(self)

# Potion Lookups
static var _potion_properties = {
	Potion.TYPE.EMPTY : {
		"color": Color(0, 0, 0, 0), # Transparent for empty
		"drop": null,
		"fill_material": null
	},
	Potion.TYPE.RED : {
		"color": Color.html("ee0030"),
		"drop": preload("res://Prefabs/Brewing/Drops/PotionDrop1.tscn"),
		"fill_material": preload("res://Materials/Potions/PotionRed.tres")
	},
	Potion.TYPE.GREEN : {
		"color": Color.html("44cd38"),
		"drop": preload("res://Prefabs/Brewing/Drops/PotionDrop2.tscn"),
		"fill_material": preload("res://Materials/Potions/PotionGreen.tres")
	},
	Potion.TYPE.ORANGE : {
		"color": Color.html("e1b227"),
		"drop": preload("res://Prefabs/Brewing/Drops/PotionDrop3.tscn"),
		"fill_material": preload("res://Materials/Potions/PotionOrange.tres")
	},
	Potion.TYPE.BLUE : {
		"color": Color.html("0844ff"),
		"drop": preload("res://Prefabs/Brewing/Drops/PotionDrop4.tscn"),
		"fill_material": preload("res://Materials/Potions/PotionBlue.tres")
	},
	Potion.TYPE.PURPLE : {
		"color": Color.html("c929ce"),
		"drop": preload("res://Prefabs/Brewing/Drops/PotionDrop5.tscn"),
		"fill_material": preload("res://Materials/Potions/PotionPurple.tres")
	},
	Potion.TYPE.CYAN : {
		"color": Color.html("1bc2c0"),
		"drop": preload("res://Prefabs/Brewing/Drops/PotionDrop6.tscn"),
		"fill_material": preload("res://Materials/Potions/PotionCyan.tres")
	},
	Potion.TYPE.GREY : {
		"color": Color.html("a1a1a1"),
		"drop": preload("res://Prefabs/Brewing/Drops/PotionDrop7.tscn"),
		"fill_material": preload("res://Materials/Potions/PotionGrey.tres")
	}
}

static func get_potion_data(type : Potion.TYPE, property : Potion.PROPERTIES):
	var _property : String = PROPERTIES.keys()[property].to_lower()
	return _potion_properties[type][_property]
