@icon("res://Textures/SeedBag.png")
class_name SeedBag
extends XRToolsPickable

## Seed to be spawned
@export var seed : PackedScene

func _on_picked_up(pickable):
	# Determine which hand picked up the seed bag
	var player_hand : XRToolsFunctionPickup = pickable.get_picked_up_by()
	
	# Instantly drop seed bag so it stays in place
	drop()
	
	# Play jiggle animation
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.9, 0.9, 0.9), 0.05)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.05)
	
	# Instantiate new seed
	var seed_instance : XRToolsPickable = seed.instantiate()
	add_sibling(seed_instance)
	seed_instance.global_position = player_hand.global_position
	
	# Force seed into players hand
	player_hand._pick_up_object(seed_instance)
