class_name IngredientUI
extends Panel

@onready var icon_rect : TextureRect = $"CenterContainer/Ingredient/Ingredient Icon"
@onready var amount_label : Label = $CenterContainer/Ingredient/Amount

func set_icon(icon : Texture2D):
	icon_rect.texture = icon

func set_amount(amount : int) -> bool:
	var new_amount = str(amount) + "x"
	
	var changed : bool = false
	if new_amount != amount_label.text:
		changed = true
	
	amount_label.text = str(amount) + "x"
	
	return changed

func set_complete():
	var tween : Tween = create_tween()
	tween.tween_property($Complete, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

func show_highlight(duration : float, strength : int):
	var style_box : StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", style_box)
	
	var tween : Tween = create_tween()
	tween.tween_method(style_box.set_border_width_all, 2, strength, duration)
	tween.tween_method(style_box.set_border_width_all, strength, 2, duration)
