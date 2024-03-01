class_name HubBase
extends XRToolsSceneBase

# More to come...

func _process(delta) -> void:
	if Input.is_key_pressed(KEY_0):
		_on_load_scene_button_button_pressed(null)

func _on_load_scene_button_button_pressed(button: Variant) -> void:
	# Load debug scene
	load_scene("res://Scenes/GameScene.tscn", {
		"level": 1
	})
