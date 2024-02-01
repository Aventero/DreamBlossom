class_name IngredientUI
extends Panel

@onready var icon_rect : TextureRect = $"CenterContainer/Ingredient/Ingredient Icon"
@onready var amount_label : Label = $CenterContainer/Ingredient/Amount

func set_icon(icon : Texture2D):
	icon_rect.texture = icon

func set_amount(amount : int):
	amount_label.text = str(amount) + "x"
