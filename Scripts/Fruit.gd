class_name Fruit
extends XRToolsPickable

@onready var fruit_event : FruitEvent = $"../.."
var _first_pickup : bool = false

func _ready():
	print("FRUIT READY!")
	super()
	
func _process(delta):
	pass

func _on_picked_up(picked_fruit : Fruit):
	if not _first_pickup:
		_first_pickup = true
		var root = get_tree().current_scene
		get_parent().remove_child(self)
		root.add_child(self)
		fruit_event.first_fruit_pickup(picked_fruit)
