@icon("res://Textures/EditorIcons/Scene.png")
class_name LevelCompleteBase
extends XRToolsSceneBase

@onready var level_complete_UI : LevelCompleteFrameUI = $"Level Complete Viewport/Level Complete"

func scene_loaded(user_data = null):
	super(user_data)
	
	# Set game statistics
	level_complete_UI.set_data(user_data["time"], user_data["failed_orders"], user_data["grown_plants"])

func _on_hub_button_button_pressed(button: Variant) -> void:
	load_scene("res://Scenes/HubScene.tscn", null)
