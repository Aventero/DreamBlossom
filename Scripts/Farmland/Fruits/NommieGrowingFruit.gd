class_name NommieGrowingFruit
extends Node3D

@onready var outline : Node3D = $Model/Outline

func set_outline(visiblity : bool) -> void:
	outline.visible = visiblity

func enable_fertilize_event(event : NommieFertilizeEvent) -> void:
	# Enable outline
	set_outline(true)
	
	# Setup event
	for child in get_children():
		if child is NommieFertilize:
			child.setup(event)
