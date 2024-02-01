class_name Recipe
extends Node

@export_category("Recipe - Input")
@export var input : Array[RecipeInputData]
@export_category("Recipe - Output")
@export var output : RecipeOutputData

var _input_ingredient_lookup : Dictionary

func _ready():
	# Setup lookup
	for data in input:
		_input_ingredient_lookup[data.ingredient] = data.amount

func get_recipe_hash() -> int:
	var input_types : Array
	for i in input:
		input_types.append(i.ingredient)
	
	input_types.sort()
	return input_types.hash()
