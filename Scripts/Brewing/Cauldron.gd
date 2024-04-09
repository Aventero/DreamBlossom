class_name Cauldron
extends Node3D

@export_category("Potion Fluid Settings")
@export var default_fluid_height : float = 0.012
@export var empty_fluid_height : float = -0.15
@export var jiggle_height : float = 0.05

@onready var potion_fluid : MeshInstance3D = $Model/Water
@onready var collision_shape : CollisionShape3D = $PotionDropArea/CollisionShape
@onready var mixture : Label3D = $Mixture

var _fluid_material : ShaderMaterial
var _mixture = []

var _potions = [
	preload("res://Prefabs/Brewing/Potions/Potion1.tscn"),
	preload("res://Prefabs/Brewing/Potions/Potion2.tscn"),
	preload("res://Prefabs/Brewing/Potions/Potion3.tscn"),
	preload("res://Prefabs/Brewing/Potions/Potion4.tscn"),
	preload("res://Prefabs/Brewing/Potions/Potion5.tscn"),
	preload("res://Prefabs/Brewing/Potions/Potion6.tscn"),
	preload("res://Prefabs/Brewing/Potions/Potion7.tscn"),
]

func _ready() -> void:
	# Get potion fluid material
	_fluid_material = potion_fluid.get_surface_override_material(0)

func _on_potion_drop_area_body_entered(body: Node3D) -> void:
	# Check if object is potion drop
	if body is PotionDrop:
		_handle_drop(body)
	
	# Check if object is empty potion
	if body is EmptyPotion:
		_handle_empty_potion(body)

func _handle_drop(drop : PotionDrop) -> void:
	# Only accept "base" drops
	if not drop.type == 1 and not drop.type == 2 and not drop.type == 4:
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
	mixture.text = str(get_mixture())

func _handle_empty_potion(empty_potion : EmptyPotion) -> void:
	# Do nothing if cauldron is empty
	if _mixture.is_empty():
		return
	
	var controller_pickup : XRToolsFunctionPickup = empty_potion.get_picked_up_by()
	
	# Replace empty potion with correct potion
	var potion : Potion = _potions[get_mixture() - 1].instantiate()
	potion.global_transform = empty_potion.global_transform
	
	# Drop empty potion
	empty_potion.drop()
	empty_potion.queue_free()
	
	add_child(potion)
	
	# Set potion data
	potion.set_data(4)
	
	# Force new potion in hand
	controller_pickup._pick_up_object(potion)
	
	# Empty cauldron
	_empty_cauldron()

func get_mixture() -> int:
	var mix : int = 0
	
	for type in _mixture:
		mix += type
	
	return mix

func _fill_cauldron(type : int) -> void:
	# Color in fluid
	_fluid_material.set_shader_parameter("base_color", Potion.get_color(type))
	
	# Make fluid visible
	var fluid_tween : Tween = create_tween().set_parallel()
	fluid_tween.tween_property(potion_fluid, "position:y", default_fluid_height, 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	fluid_tween.tween_method(_update_fluid_alpha, 0.0, 1.0, 0.2)

func _empty_cauldron() -> void:
	# Clear mixture
	_mixture.clear()
	
	# Update mixture label
	mixture.text = ""
	
	# Make fluid invisible
	var fluid_tween : Tween = create_tween().set_parallel()
	fluid_tween.tween_property(potion_fluid, "position:y", empty_fluid_height, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fluid_tween.tween_method(_update_fluid_alpha, 1.0, 0.0, 0.2).set_delay(0.55)

func _jiggle_cauldron(type : int) -> void:
	# Make fluid jiggle
	var fluid_tween : Tween = create_tween()
	fluid_tween.tween_property(potion_fluid, "position:y", -jiggle_height, 0.25).as_relative().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fluid_tween.tween_method(_update_fluid_color, _fluid_material.get_shader_parameter("base_color"), Potion.get_color(type), 0.1)
	fluid_tween.tween_property(potion_fluid, "position:y", jiggle_height, 0.5).as_relative().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _update_fluid_color(color : Color) -> void:
	_fluid_material.set_shader_parameter("base_color", color)

func _update_fluid_alpha(value : float) -> void:
	_fluid_material.set_shader_parameter("alpha", value)

func _on_empty_cauldron_button_button_pressed(button: Variant) -> void:
	if _mixture.is_empty():
		return
	
	# Empty cauldron
	_empty_cauldron()
