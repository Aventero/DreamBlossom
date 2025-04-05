@icon("res://Textures/EditorIcons/SeedBag.png")
@tool
class_name ItemBag
extends XRToolsPickable

# Item to spawn
@export var item : PackedScene

@export_category("Pickup Jiggle Settings")
# Difference in scale while jiggle
@export var jiggle_strength : float = 0.1
# Duration of jiggle
@export var jiggle_duration : float = 0.1

func _on_picked_up(pickable):
	# Determine which hand picked up the item bag
	var player_hand : XRToolsFunctionPickup = pickable.get_picked_up_by()
	
	# Instantly drop item bag so it stays in place
	drop()
	
	# Play jiggle animation
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.0 - jiggle_strength, 1.0 - jiggle_strength, 1.0 - jiggle_strength), jiggle_duration / 2.0)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), jiggle_duration / 2.0)
	
	# Instantiate new item
	var item_instance : XRToolsPickable = item.instantiate()
	add_sibling(item_instance)
	item_instance.global_position = player_hand.global_position
	
	# Force item into players hand
	player_hand._pick_up_object(item_instance)
	
	# Add to inactivity manager
	InactivityManager.get_instance().add_node(item_instance, true)
