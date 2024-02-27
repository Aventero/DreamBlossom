@icon("res://Textures/EditorIcons/TextureLoader.png")
class_name TextureLoader
extends Node

static var instance : TextureLoader

# Hold all textures for all ingredients. Order is defined in Ingredients-Enum !
@export var ingredients_textures : Array[IngredientTexture]

var _ingredients_texture_lookup : Dictionary

static func get_instance() -> TextureLoader:
	return instance

func _ready():
	# Setup singleton
	if instance == null:
		instance = self
	else:
		queue_free()
		
	# Fill lookup
	for ingredient in ingredients_textures:
		_ingredients_texture_lookup[ingredient.type] = ingredient.texture

func get_ingredient_icon(type : Ingredient.Type):
	if _ingredients_texture_lookup.has(type):
		return _ingredients_texture_lookup[type]
	return null
