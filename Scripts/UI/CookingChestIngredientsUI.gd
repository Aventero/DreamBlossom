class_name CookingChestIngredientsUI
extends HBoxContainer

@onready var ingredient_ui = preload("res://Prefabs/UI/IngredientUI.tscn")

func update(ingredients : Dictionary):
	# Clear previous ui
	clear_ingredients()
	
	for ingredient in ingredients:
		_spawn_ingredient_ui(ingredient, ingredients[ingredient])

func _spawn_ingredient_ui(ingredient : Ingredient.Type, amount : int):
	var _ingredient_ui : IngredientUI = ingredient_ui.instantiate()
	add_child(_ingredient_ui)
	
	# Fill ingredient ui with data
	_ingredient_ui.set_icon(TextureLoader.get_instance().get_ingredient_icon(ingredient))
	_ingredient_ui.set_amount(amount)

func clear_ingredients():
	for ingredient in get_children():
		ingredient.queue_free()

func _on_cook_button_pressed(_button):
	var tween : Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2)
	tween.tween_callback(clear_ingredients)
	
	await tween.finished
	modulate = Color(1.0, 1.0, 1.0, 1.0)
