class_name Cauldron
extends Node3D

@export var default_fluid_height : float = 0.012
@export var empty_fluid_height : float = -0.15
@export var jiggle_height : float = 0.075

@onready var potion_fluid : MeshInstance3D = $Model/Water
@onready var collision_shape : CollisionShape3D = $PotionDropArea/CollisionShape
@onready var mixture : Label3D = $Mixture

# Pipe objects for empty jiggle
@onready var pipe_parts = [
	$Model/Pipe_0,
	$Model/Pipe_1,
	$Model/Pipe_2,
	$Model/Pipe_3,
	$Model/Pipe_4,
	$Model/Pipe_5,
	$Model/Pipe_6,
	$Model/Pipe_7,
]

var drops_per_potion : int = 5

var _fluid_material : ShaderMaterial
var _mixture = []
var _fluid_tween : Tween

func _ready() -> void:
	# Get potion fluid material
	_fluid_material = potion_fluid.get_surface_override_material(0)

func disable_cauldron() -> void:
	queue_free()

func setup(p_drops_per_potion : int) -> void:
	# Set data
	drops_per_potion = p_drops_per_potion

func _on_potion_drop_area_body_entered(body: Node3D) -> void:
	# Check if object is potion drop
	print("body ", body)
	if body is PotionDrop:
		_handle_drop(body)
	
	# Check if object is empty potion
	if body is Potion and body.type == Potion.TYPE.EMPTY:
		_handle_empty_potion(body)

func _handle_drop(drop : PotionDrop) -> void:
	# Only accept "base" drops
	if not drop.type == Potion.TYPE.RED and \
	   not drop.type == Potion.TYPE.GREEN and \
	   not drop.type == Potion.TYPE.BLUE:
		return
	
	# Splash drop
	drop.cauldron_splash(drop.global_position - Vector3(0, 0.1, 0))
	
	# Fill cauldron if empty
	if _mixture.is_empty():
		# Adjust mixture
		_mixture.append(drop.type)
		
		# Fill cauldron
		_fill_cauldron(drop.type)
	else:
		# Adjust mixture
		if not _mixture.has(drop.type):
			_mixture.append(drop.type)
		
		# Jiggle fluid
		_jiggle_cauldron(get_mixture(), true)
	
	# Update mixture display
	_update_mixture_display(drop.type)

func _update_mixture_display(_type : int) -> void:
	var new_mixture : String = str(get_mixture())
	
	# Make text jiggle
	var label_tween = create_tween()
	label_tween.tween_property(mixture, "scale", Vector3(0.2, 0.2, 0.2), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	label_tween.tween_callback(func(): mixture.text = new_mixture)
	label_tween.tween_property(mixture, "scale", Vector3(0.4, 0.4, 0.4), 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _handle_empty_potion(empty_potion : Potion) -> void:
	# Do nothing if cauldron is empty
	if _mixture.is_empty():
		print("empty cauldron")
		return
	
	# Fill potion with given potion type
	print("filling?")
	empty_potion.fill_potion(get_mixture(), drops_per_potion)
	
	# Play potion jiggle effect
	_jiggle_cauldron(Potion.TYPE.EMPTY, false)

func get_mixture() -> int:
	var mix : int = 0
	
	for type in _mixture:
		mix += type
	
	return mix

func _fill_cauldron(type : Potion.TYPE) -> void:
	# Color in fluid
	_fluid_material.set_shader_parameter("base_color", Potion.get_potion_data(type, Potion.PROPERTIES.COLOR))
	
	# Make fluid visible
	if _fluid_tween and _fluid_tween.is_running():
		_fluid_tween.kill()
	
	_fluid_tween= create_tween().set_parallel()
	_fluid_tween.tween_property(potion_fluid, "position:y", default_fluid_height, 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Tween alpha value with different tween
	var alpha_tween : Tween = create_tween()
	alpha_tween.tween_method(_update_fluid_alpha, _fluid_material.get_shader_parameter("alpha"), 1.0, 0.2)

func _empty_cauldron() -> void:
	# Clear mixture
	_mixture.clear()
	
	# Update mixture label
	var label_tween = create_tween()
	label_tween.tween_property(mixture, "scale", Vector3(0.0, 0.0, 0.0), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	label_tween.tween_callback(func(): mixture.text = "")
	label_tween.tween_callback(func(): mixture.scale = Vector3(0.2, 0.2, 0.2))
	
	# Make fluid invisible
	if _fluid_tween and _fluid_tween.is_running():
		_fluid_tween.kill()
	
	_fluid_tween= create_tween().set_parallel()
	_fluid_tween.tween_property(potion_fluid, "position:y", empty_fluid_height, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_fluid_tween.tween_method(_update_fluid_alpha, 1.0, 0.0, 0.2).set_delay(1.8)
	
	# Start pipe jiggles
	var part_count : int = 0
	
	for part in pipe_parts:
		var pipe_jiggle : Tween = create_tween()
		
		# Jiggle one
		pipe_jiggle.tween_interval(part_count * 0.1)
		pipe_jiggle.tween_property(part, "scale", 1.2 * Vector3.ONE, 0.2)
		pipe_jiggle.tween_interval(0.1)
		pipe_jiggle.tween_property(part, "scale", Vector3.ONE, 0.2)
		
		# Jiggle two
		pipe_jiggle.tween_interval(0.4)
		pipe_jiggle.tween_property(part, "scale", 1.1 * Vector3.ONE, 0.2)
		pipe_jiggle.tween_interval(0.2)
		pipe_jiggle.tween_property(part, "scale", Vector3.ONE, 0.2)
		
		part_count += 1

func _jiggle_cauldron(type : Potion.TYPE, should_change_color : bool) -> void:
	if _fluid_tween and _fluid_tween.is_running():
		_fluid_tween.kill()
	
	# Make fluid jiggle
	_fluid_tween = create_tween()
	_fluid_tween.tween_property(potion_fluid, "position:y", jiggle_height, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Update color of fluid
	if should_change_color:
		_fluid_tween.tween_method(_update_fluid_color, _fluid_material.get_shader_parameter("base_color"), Potion.get_potion_data(type, Potion.PROPERTIES.COLOR), 0.1)
	
	_fluid_tween.tween_property(potion_fluid, "position:y", default_fluid_height, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _update_fluid_color(color : Color) -> void:
	_fluid_material.set_shader_parameter("base_color", color)

func _update_fluid_alpha(value : float) -> void:
	_fluid_material.set_shader_parameter("alpha", value)

func _on_empty_cauldron_button_button_pressed() -> void:
	if _mixture.is_empty():
		return
	
	# Empty cauldron
	_empty_cauldron()
