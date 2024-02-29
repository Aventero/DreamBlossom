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

func enable_watering_event(event : NommieWateringEvent) -> void:
	# Enable outline
	set_outline(true)
	
	# Setup event 
	for child in get_children():
		if child is NommieWatering:
			child.setup(event)

func enable_feeding_event(event : NommieFeedingEvent) -> void:
	# Enable outline
	set_outline(true)
	
	# Setup event 
	for child in get_children():
		if child is NommieFeeding:
			child.setup(event)
