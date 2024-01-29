@icon("res://Textures/Stage.png")
class_name Level
extends Node3D

signal completed

@export_flags("Fertilizer_Blue", "Fertilizer_Yellow", "Fertilizer_Green", "Scissors", "MusicBox") var unlocked

enum Flags {
	Fertilizer_Blue = 1,
	Fertilizer_Yellow = 2,
	Fertilizer_Green = 4,
	Scissors = 8,
	MusicBox = 16
}

# Get most current quest from this level
func get_quest() -> Quest:
	if get_child_count() > 0:
		return get_child(0)
	
	completed.emit()
	return null
