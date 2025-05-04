@tool
extends XRToolsPickable
class_name Blossy

@export var textbox: Sprite3D
@export var spawnpoint: Node3D
@export_tool_button("respawn") var respawning = enable_respawn
var can_respawn = false
var squish_tween: Tween

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

func squish() -> Tween:
	if squish_tween and squish_tween.is_valid():
		squish_tween.kill()
		
	# Quick tween to squish and going back to normal
	squish_tween = create_tween()
	
	# First squish down and widen
	squish_tween.tween_property(self, "scale", Vector3(1.3, 0.7, 1.3), 0.1)
	
	# Then return to normal size with a slight bounce
	squish_tween.tween_property(self, "scale", Vector3(0.9, 1.1, 0.9), 0.1)
	squish_tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	
	return squish_tween

func _on_action_pressed(_pickable: XRToolsPickable) -> void:
	squish()

func enable_respawn() -> void:
	can_respawn = true

func set_to_respawn() -> void:
	squish().tween_callback(func(): 
		global_position = spawnpoint.global_position
		global_rotation = spawnpoint.global_rotation)
	
func _on_dropped(pickable: Variant) -> void:
	if can_respawn:
		var tween = squish().tween_callback(set_to_respawn).set_delay(0.3)
