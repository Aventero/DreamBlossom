@icon("res://Textures/EditorIcons/WaterDrop.png")
class_name WaterDrop
extends RigidBody3D

@onready var timer : Timer = $DestroyTimer

func start(time: float):
	timer.start(time)

func _on_destroy_timer_timeout():
	queue_free()
