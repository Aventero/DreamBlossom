@tool
@icon("res://Textures/EditorIcons/Preview.png")
class_name ModelPreview
extends Node3D

@export var show_preview : bool = true:
	set(value):
		show_preview = value
		
		if get_child_count() > 0:
			get_child(0).visible = value
		else:
			_ready()

@export_file("*.tscn") var preview_model : String

func _ready() -> void:
	if Engine.is_editor_hint():
		if not show_preview:
			return
		
		if not preview_model:
			return
		
		# Spawn model
		for child in get_children():
			child.queue_free()
		
		# Add model to scene
		var model_instance = ResourceLoader.load(preview_model).instantiate()
		add_child(model_instance)
