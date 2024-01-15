@icon("res://Textures/GrowingPlant.png")
extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Grow");
	pass # Replace with function body.

func initialize(grow_position : Vector3):
	position = grow_position
