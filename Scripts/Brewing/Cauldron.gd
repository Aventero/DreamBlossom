class_name Cauldron
extends Node3D

@export var default_fluid_height : float = 0.012
@export var empty_fluid_height : float = -0.15
@export var jiggle_height : float = 0.075

@onready var potion_fluid : MeshInstance3D = $Model/Water
@onready var collision_shape : CollisionShape3D = $PotionDropArea/CollisionShape
@onready var mixture : Label3D = $Mixture

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
		_jiggle_cauldron(get_mixture())
	
	# Update mixture display
	_update_mixture_display(drop.type)

func _update_mixture_display(type : int) -> void:
	var new_mixture : String = str(get_mixture())
	
	# Make text jiggle
	var label_tween = create_tween()
	label_tween.tween_property(mixture, "scale", Vector3(0.2, 0.2, 0.2), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	label_tween.tween_callback(func(): mixture.text = new_mixture)
	label_tween.tween_property(mixture, "scale", Vector3(0.4, 0.4, 0.4), 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _handle_empty_potion(empty_potion : Potion) -> void:
	# Do nothing if cauldron is empty
	if _mixture.is_empty():
		return
	
	# Fill potion with given potion type
	empty_potion.fill_potion(get_mixture(), drops_per_potion)
	
	# Play potion jiggle effect
	_jiggle_cauldron(-1)

func get_mixture() -> int:
	var mix : int = 0
	
	for type in _mixture:
		mix += type
	
	return mix

func _fill_cauldron(type : Potion.TYPE) -> void:
	# Color in fluid
	#_fluid_material.set_shader_parameter("base_color", Potion.get_color(type))
	_fluid_material.set_shader_parameter("base_color", Potion.get_potion_data(type, Potion.PROPERTIES.COLOR))
	
	# Make fluid visible
	if _fluid_tween and _fluid_tween.is_running():
		_fluid_tween.kill()
	
	_fluid_tween= create_tween().set_parallel()
	_fluid_tween.tween_property(potion_fluid, "position:y", default_fluid_height, 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_fluid_tween.tween_method(_update_fluid_alpha, 0.0, 1.0, 0.2)

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
	_fluid_tween.tween_property(potion_fluid, "position:y", empty_fluid_height, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_fluid_tween.tween_method(_update_fluid_alpha, 1.0, 0.0, 0.2).set_delay(1.1)

func _jiggle_cauldron(type : Potion.TYPE) -> void:
	if _fluid_tween and _fluid_tween.is_running():
		_fluid_tween.kill()
	
	# Make fluid jiggle
	_fluid_tween = create_tween()
	_fluid_tween.tween_property(potion_fluid, "position:y", jiggle_height, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Update color of fluid
	if type != -1:
		#_fluid_tween.tween_method(_update_fluid_color, _fluid_material.get_shader_parameter("base_color"), Potion.get_color(type), 0.1)
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
