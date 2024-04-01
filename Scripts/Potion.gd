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

var _current_drop_count : int
var _drop_progress : float = 0.0
var _reduction_tween : Tween = null

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

func _lerp_fill(percentage : float):
	flask_fill.set_instance_shader_parameter("fill_percentage", percentage)

func _on_picked_up(pickable: Variant) -> void:
	# Despawn stomp
	flask_stomp.visible = false

func _on_dropped(pickable: Variant) -> void:
	# Spawn stomp
	flask_stomp.visible = true
	
	# Start reduction tween
	if _reduction_tween and _reduction_tween.is_running():
		_reduction_tween.kill()
	
	_reduction_tween = create_tween()
	_reduction_tween.tween_property(self, "_drop_progress", 0.0, 0.1)
	_reduction_tween.tween_callback(func(): drop_model.scale = Vector3.ZERO)
