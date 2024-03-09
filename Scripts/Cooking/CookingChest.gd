class_name CookingChest
extends Node3D

@onready var chest_lid : Node3D = $Model/Top
@onready var ingredient_ui : CookingChestIngredientsUI = $"Display Viewport/Cooking Chest Ingredients"

var ingredients : Dictionary = {}
var ingredient_instances : Dictionary = {}

var _is_cooking : bool = false

func _ready():
	_open_chest()

func _on_trigger_body_entered(body):
	if body.is_in_group("Ingredient"):
		# Get type of ingredient
		var ingredient : Ingredient = body
		
		# Add ingredient to content
		if ingredients.has(ingredient.type):
			ingredients[ingredient.type] = ingredients[ingredient.type] + 1
		else:
			ingredients[ingredient.type] = 1
		
		# Append current ingredient to instances. Using dictionary for fast lookup
		ingredient_instances[body] = null
		
		ingredient_ui.update(ingredients)

func _on_trigger_body_exited(body):
	if body.is_in_group("Ingredient"):
		# Get type of ingredient
		var ingredient : Ingredient = body
		
		# Remove current ingredient from instances
		ingredient_instances.erase(body)
		
		# Add ingredient to content
		if ingredients.has(ingredient.type):
			var new_amount : int = ingredients[ingredient.type] - 1
			
			if new_amount > 0:
				ingredients[ingredient.type] = new_amount
			else:
				ingredients.erase(ingredient.type)
		
		ingredient_ui.update(ingredients)

func _on_cook_button_pressed(button):
	if _is_cooking:
		return
	_is_cooking = true
	
	# Close chest
	await _close_chest().finished
	
	# Jiggle chest
	await _chest_jiggle().finished
	await get_tree().create_timer(0.5).timeout
	
	# Delete ingredients
	for ingredient in ingredient_instances:
		ingredient.queue_free()
	ingredient_instances.clear()
	
	# Check recipe
	var cooked_object : PackedScene = RecipeManager.get_instance().check_recipe(ingredients)
	
	if cooked_object:
		# Instantiate cooked object
		var cooked_instance = cooked_object.instantiate()
		$"Cooked Spawnpoint".add_child(cooked_instance)
	else:
		# Shake chest
		await _chest_shake().finished
	
	# Open chest
	await _open_chest().finished
	
	_is_cooking = false

func _open_chest():
	var tween : Tween = create_tween()
	tween.tween_property(chest_lid, "rotation", Vector3(-2.44, 0, 0), 0.5)
	return tween

func _close_chest():
	var tween : Tween = create_tween()
	tween.tween_property(chest_lid, "rotation", Vector3(0, 0, 0), 0.5)
	return tween

func _chest_jiggle():
	var tween : Tween = create_tween()
	tween.set_loops(4)
	tween.tween_property($Model, "scale", Vector3(1.0, 1.1, 1.0), 0.2)
	tween.tween_property($Model, "scale", Vector3(1.1, 0.9, 1.1), 0.2)
	tween.tween_property($Model, "scale", Vector3(1, 1, 1), 0.1)
	return tween

func _chest_shake():
	var tween : Tween = create_tween()
	tween.set_loops(2)
	tween.tween_property($Model, "rotation", Vector3(0, 0.1570796, 0), 0.05)
	tween.tween_property($Model, "rotation", Vector3(0, 0, 0), 0.05)
	tween.tween_property($Model, "rotation", Vector3(0, -0.1570796, 0), 0.05)
	tween.tween_property($Model, "rotation", Vector3(0, 0, 0), 0.05)
	return tween
