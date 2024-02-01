class_name PageUI
extends Panel

@onready var recipe_name : Label = $"VBoxContainer/Recipe Name"
@onready var input : Control = $VBoxContainer/Input
@onready var output : Control = $VBoxContainer/Output

@onready var ingredient_ui = preload("res://Prefabs/UI/IngredientUI.tscn")

func set_recipe_name(name : String):
	recipe_name.text = name

func fill_recipe_input(input_data : Array[RecipeInputData]):
	for data in input_data:
		_spawn_ingredient_ui(input, data.ingredient, data.amount)

func fill_recipe_output(data : RecipeOutputData):
	_spawn_ingredient_ui(output, data.ingredient, 1)

func _spawn_ingredient_ui(parent : Control, ingredient : Ingredient.Type, amount : int):
	var ingredient_ui : IngredientUI = ingredient_ui.instantiate()
	parent.add_child(ingredient_ui)
	
	# Fill ingredient ui with data
	ingredient_ui.set_icon(TextureLoader.get_instance().get_ingredient_icon(ingredient))
	ingredient_ui.set_amount(amount)

func clear_icons():
	# Clear input icons
	for child in input.get_children():
		child.queue_free()
	
	# Clear output icons
	for child in output.get_children():
		child.queue_free()
