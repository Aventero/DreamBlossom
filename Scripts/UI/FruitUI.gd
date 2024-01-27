class_name FruitUI
extends Panel

@onready var icon_rect : TextureRect = $"CenterContainer/Fruit Content/Fruit Icon"
@onready var amount_label : Label = $"CenterContainer/Fruit Content/HBoxContainer/Amount"
@onready var target_label : Label = $"CenterContainer/Fruit Content/HBoxContainer/Target"

func set_icon(icon : Texture2D):
	icon_rect.texture = icon

func set_amount(amount : int):
	amount_label.text = str(amount)

func set_target(amount : int):
	target_label.text = str(amount)
