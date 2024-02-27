@icon("res://Textures/EditorIcons/Fertilizer.png")
class_name Fertilizer
extends XRToolsPickable

enum Type {
	BLUE,
	ORANGE,
	GREEN
}

@export var type : Type
