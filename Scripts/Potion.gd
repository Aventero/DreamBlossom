@icon("res://Textures/EditorIcons/Potion.png")
class_name Potion
extends XRToolsPickable

@export_category("Pouring Settings")
@export var infinite_drops : bool = false
@export var drop_count : int = 3
@export var tilt_angle : float 
@export var drop_fill_speed : float = 1.0
@export var max_drop_size : float = 8.0

@export_category("Drop")
@export var potion_drop : PackedScene

@onready var drop_model : Node3D = $Drop/Drop
@onready var flask_stomp : Node3D = $Model/Stomp
@onready var flask_fill : MeshInstance3D = $Model/Fill

@onready var potion_type : Label3D = $Indicator/PotionType
@onready var empty_potion : PackedScene = preload("res://Prefabs/Brewing/Potions/EmptyPotion.tscn")

var _current_drop_count : int
var _drop_progress : float = 0.0
var _reduction_tween : Tween = null
var _stomp_tween : Tween = null

func _ready() -> void:
	super()
	
	# Set data
	_current_drop_count = drop_count

func _process(delta: float) -> void:
	# Update drop size
	if _drop_progress > 0.0:
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
			drop_model.scale = Vector3.ZERO
			
			# Handle drop
			_handle_drop()
	else:
		# Start reduction tween
		if _reduction_tween and _reduction_tween.is_running():
			_reduction_tween.kill()
		
		_reduction_tween = create_tween()
		_reduction_tween.tween_property(self, "_drop_progress", 0.0, 0.1)
		_reduction_tween.tween_callback(func(): drop_model.scale = Vector3.ZERO)

func _handle_drop() -> void:
	var drop_instance : RigidBody3D = potion_drop.instantiate()
	get_parent().add_child(drop_instance)
	
	# Set position & rotation
	drop_instance.global_position = $Drop.global_position
	drop_instance.global_rotation = $Drop.global_rotation
	
	# Update fill shader
	if not infinite_drops:
		var old_fill_percentage : float = float(_current_drop_count) / float(drop_count)
		var new_fill_percentage : float = float(_current_drop_count - 1) / float(drop_count)
		
		var fill_tween : Tween = create_tween()
		fill_tween.tween_method(_lerp_fill, old_fill_percentage, new_fill_percentage, 0.2)
		
		# Reduce drop count
		_current_drop_count -= 1
		
		if _current_drop_count <= 0:
			fill_tween.tween_callback(_replace_with_empty).set_delay(0.1)

func _replace_with_empty() -> void:
	# Hide label
	await hide_type_label().finished
	
	# Replace with empty potion
	var empty_potion : EmptyPotion = empty_potion.instantiate()
	add_sibling(empty_potion)
	empty_potion.global_position = global_position
	empty_potion.global_rotation = global_rotation
	
	if is_picked_up():
		var controller_pickup : XRToolsFunctionPickup = get_picked_up_by()
		controller_pickup._pick_up_object(empty_potion)
	
	queue_free()

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

func set_data(p_drop_count : int) -> void:
	potion_type.scale = Vector3.ZERO
	
	# Update drop variables
	drop_count = p_drop_count
	_current_drop_count = drop_count
	infinite_drops = false
	
	# Update shader parameter
	_lerp_fill(1.0)
	
	# Update type scale
	show_type_label()
	
	# Lerp stomp
	if _stomp_tween and _stomp_tween.is_running():
		_stomp_tween.kill()
	_stomp_tween = create_tween()
	_stomp_tween.tween_property(flask_stomp, "scale", Vector3(0.016, 0.016, 0.016), 0.1)

func show_type_label() -> Tween:
	var tween : Tween = create_tween()
	tween.tween_property(potion_type, "scale", Vector3(0.4, 0.4, 0.4), 0.25)
	return tween

func hide_type_label() -> Tween:
	var tween : Tween = create_tween()
	tween.tween_property(potion_type, "scale", Vector3.ZERO, 0.25)
	return tween

# Potion Color lookup
static var _potion_colors = {
	1: "ee0030",
	2: "44cd38",
	3: "e1b227",
	4: "0844ff",
	5: "c929ce",
	6: "1bc2c0",
	7: "a1a1a1",
}

static func get_color(type : int) -> Color:
	if not _potion_colors.has(type):
		return Color.WHITE
	return Color.html(_potion_colors[type])
