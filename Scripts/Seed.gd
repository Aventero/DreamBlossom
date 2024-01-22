@icon("res://Textures/Seed.png")
class_name Seed
extends XRToolsPickable

@export var plant : PackedScene

# Ensures that seed is only planted once
var planted : bool = false
