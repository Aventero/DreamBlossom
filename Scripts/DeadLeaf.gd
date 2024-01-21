extends PruneAble
class_name DeadLeaf

@onready var prune_event : PruneEvent = $"../.."
@export var falling_leaf_particle : PackedScene
var _scissors_inside_leaf : bool = false
var _scissors : Scissors


func _ready():
	pass 

func prune():
	# Emit that is cut
	prune_event.pruned_leaf.emit()
	
	# Add falling particle to parent
	var falling_leaf : GPUParticles3D = falling_leaf_particle.instantiate()
	get_parent().add_child(falling_leaf)
	falling_leaf.restart()
	
	# Remove it
	queue_free()
