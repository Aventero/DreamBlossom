@icon("res://Textures/EditorIcons/Seed.png")
class_name Seed
extends XRToolsPickable

@export var plant : String

# Ensures that seed is only planted once
var planted : bool = false
