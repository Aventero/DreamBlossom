@icon("res://Textures/Cog.png")
class_name RecipeManager
extends Node3D

static var instance

var _recipe_lookup : Dictionary

static func get_instance() -> RecipeManager:
	return instance

func _ready():
	# Setup singleton
	if instance == null:
		instance = self
	else:
		queue_free()
	
	# Fill recipe lookup table
	for recipe in get_children():
		var hash : int = recipe.get_recipe_hash()
		
		if _recipe_lookup.has(hash):
			_recipe_lookup[hash].append(recipe)
		else:
			_recipe_lookup[hash] = [recipe]

func check_recipe(ingredients : Dictionary) -> PackedScene:
	print(ingredients)
	
	# Calculate hash of ingredients
	var ingredient_list : Array = []
	for i in ingredients.keys():
		ingredient_list.append(i)
	
	ingredient_list.sort()
	var hash : int = ingredient_list.hash()
	
	# Check if hash can be a valid recipe
	if not _recipe_lookup.has(hash):
		print("[RECIPE] - No valid recipe found")
		return null
	
	for recipe in _recipe_lookup[hash]:
		var failed : bool = false
		
		# Check if amount is correct
		for ingredient in ingredients.keys():
			var ingredient_amount = ingredients[ingredient]
			var recipe_amount = recipe._input_ingredient_lookup[ingredient]
			
			if ingredient_amount != recipe_amount:
				failed = true
		
		if failed:
			continue
		
		print("[RECIPE] - ", recipe.name, " cooked")
		return recipe.output.object
	
	print("[RECIPE] - Recipe not executed correctly")
	return null

func get_recipe(index : int) -> Recipe:
	if index < 0 or index >= get_child_count():
		return null
	
	return get_child(index)

func get_recipe_count() -> int:
	return _recipe_lookup.size()
