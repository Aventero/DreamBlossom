class_name PullLeaf
extends Node3D

@export var dying_time = 0.5

func reparented(plant : Plant):
	plant.dying.connect(Callable(_on_dying))

func _on_dying():
	
	# plant is dying so shrink myself
	var tween : Tween  = create_tween();
	tween.tween_property(self, "scale", Vector3.ZERO, dying_time)
