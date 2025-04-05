@icon("res://Textures/EditorIcons/Scene.png")
class_name LevelFailedBase
extends XRToolsSceneBase

var _level_id : int

func scene_loaded(user_data = null):
	super(user_data)
	
	# Save level id for retry button
	_level_id = user_data["prev_level_id"]

func _on_hub_button_button_pressed(_button: Variant) -> void:
	load_scene("res://Scenes/HubScene.tscn", null)

func _on_retry_button_button_pressed(_button: Variant) -> void:
	load_scene("res://Scenes/GameScene.tscn", {
		"level": _level_id
	})
