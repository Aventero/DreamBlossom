@icon("res://Textures/ParticleCombiner.png")
class_name ParticleCombiner
extends Node3D

signal complete

@export var start_on_ready : bool = true

func _ready():
	if start_on_ready:
		_change_state(true)

func start():
	_change_state(true)

func stop():
	_change_state(false)

func _change_state(state : bool):
	for child in get_children():
		if child is GPUParticles3D:
			child.emitting = state

func _process(delta):
	if get_child_count() == 0:
		complete.emit()
		queue_free()
