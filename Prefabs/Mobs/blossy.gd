@tool
extends XRToolsPickable

@export var textbox: Sprite3D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	enabled = false
	textbox.visible = false
	scale = Vector3(0.001, 0.001, 0.001)
	
func do_initial_grow() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector3(1, 1, 1), 1.2)
	tween.tween_callback(func(): textbox.visible = true)
	tween.tween_callback(func(): enabled = true)

func squish():
	# Quick tween to squish and going back to normal
	var tween = create_tween()
	
	# First squish down and widen
	tween.tween_property(self, "scale", Vector3(1.3, 0.7, 1.3), 0.1)
	
	# Then return to normal size with a slight bounce
	tween.tween_property(self, "scale", Vector3(0.9, 1.1, 0.9), 0.1)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.1)

func _on_action_pressed(pickable: XRToolsPickable) -> void:
	squish()
