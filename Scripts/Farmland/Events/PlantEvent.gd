@icon("res://Textures/EditorIcons/PlantEvent.png")
class_name PlantEvent
extends Node3D

@warning_ignore("unused_signal")
signal event_completed

@export var icon_texture : Texture2D

func check_feasibility() -> void:
	pass

func initialize() -> void:
	pass

func cleanup() -> void:
	pass
