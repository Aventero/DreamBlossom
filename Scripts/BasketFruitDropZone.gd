extends Area3D

@onready var score_parent : Node3D = $"../Score"

var basket_counter : Label

func _ready():
	# Get reference at start because label is currently not in same scene
	basket_counter = score_parent.get_node("Viewport/Fruit Score/Score")

func _on_body_entered(fruit):
	# Increase counter by one
	var current_counter : int = basket_counter.text.to_int()
	current_counter += 1
	basket_counter.text = str(current_counter).pad_zeros(2)
	
	# Disable pick up ability
	fruit.enabled = false
