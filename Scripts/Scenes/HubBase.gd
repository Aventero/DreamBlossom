@icon("res://Textures/EditorIcons/Scene.png")
class_name HubBase
extends XRToolsSceneBase

var pressed : bool = false

func scene_loaded(user_data = null):
	super(user_data)
	
	$ResourcePreloader.reparent(get_node("../.."))

func _process(delta) -> void:
	if not pressed and Input.is_key_pressed(KEY_0):
		_on_load_scene_button_pressed($"Level Selection/Level Sandbox/LevelButton")
		pressed = true

func _on_load_scene_button_pressed(button : LevelButton) -> void:
	load_scene("res://Scenes/GameScene.tscn", {
		"level": button.level_id
	})
