class_name DeadLeaf
extends Node3D

@export var falling_leaf_particle : PackedScene

var prune_event : PruneEvent 
var _scissors_inside_leaf : bool = false
var _scissors : Scissors

func prune():
	prune_event.pruned_leaf()
	
	# Add falling particle to parent
	var falling_leaf : GPUParticles3D = falling_leaf_particle.instantiate()
	get_parent().add_child(falling_leaf)
	falling_leaf.restart()
	
	# Remove it
	queue_free()
