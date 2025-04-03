@icon("res://Textures/EditorIcons/Fertilizer.png")
class_name NommiePotionEvent
extends PlantEvent

@export var nommies : Array[NommieGrowingFruit]

var requested_potion_type : Potion.TYPE

var icon_overrides : Array[Texture2D] = [
	preload("res://Textures/EventIcons/PotionRed.png"),
	preload("res://Textures/EventIcons/PotionGreen.png"),
	preload("res://Textures/EventIcons/PotionOrange.png"),
	preload("res://Textures/EventIcons/PotionBlue.png"),
	preload("res://Textures/EventIcons/PotionPurple.png"),
	preload("res://Textures/EventIcons/PotionCyan.png"),
	preload("res://Textures/EventIcons/PotionGrey.png"),
]

var _target_amount : int = 1
var _current_amount : int = 0

func initialize():
	# Decide on request potion type
	if GameBase.level.enable_brewing:
		var random_index = randi_range(1, Potion.TYPE.size() - 1)
		requested_potion_type = Potion.TYPE.values()[random_index]
	else:
		requested_potion_type = [Potion.TYPE.RED, Potion.TYPE.GREEN, Potion.TYPE.BLUE].pick_random() # Get random potion from "base" potions
	
	# Override icon texture
	icon_texture = icon_overrides[requested_potion_type - 1]
	
	_target_amount = nommies.size()
	
	# Enable event triggers
	for nommie in nommies:
		nommie.enable_potion_event(self)

func potion_added() -> void:
	_current_amount += 1
	
	if _current_amount >= _target_amount:
		event_completed.emit()
