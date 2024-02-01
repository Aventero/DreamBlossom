@icon("res://Textures/Fertilizer.png")
class_name Fertilizer
extends XRToolsPickable

enum Type {
	BLUE,
	YELLOW,
	GREEN
}

@export var type : Type
