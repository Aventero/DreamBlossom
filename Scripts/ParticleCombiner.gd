@icon("res://Textures/EditorIcons/ParticleCombiner.png")
class_name ParticleCombiner
extends Node3D

signal complete

@export var start_on_ready : bool = true

var _max_lifetime : float = -1.0

func _ready() -> void:
	if start_on_ready:
		_change_state(true)

	# Read max lifetime
	for child in get_children():
		if not child is GPUParticles3D:
			return

		if child.lifetime > _max_lifetime:
			_max_lifetime = child.lifetime

func start() -> void:
	_change_state(true)

func stop() -> void:
	_change_state(false)

func get_max_lifetime() -> float:
	return _max_lifetime

func _change_state(state : bool) -> void:
	for child in get_children():
		if child is GPUParticles3D:
			child.emitting = state

func _process(_delta) -> void:
	if get_child_count() == 0:
		complete.emit()
		queue_free()
