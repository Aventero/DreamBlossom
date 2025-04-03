@icon("res://Textures/EditorIcons/Scene.png")
@tool
class_name GameBase
extends XRToolsSceneBase

static var level : Level
static var level_id : int

@export var level_complete_fade_offset : float = 2.0

@onready var seed_bags : SeedBagsEnabler = $"ToolArea/Seed Bags"
@onready var tools : ToolsEnabler = $"ToolArea/Variable Tools"
@onready var weed_manager : WeedManager = $Managers/WeedManager
@onready var return_manager : ReturnManager = $Managers/ReturnManager
@onready var koriko_manager : KorikoManager = $Managers/KorikoManager
@onready var cooking_chest : CookingChest = $CookingArea/CookingChest
@onready var cauldron : Cauldron = $"ToolArea/Cauldron"
@onready var recipe_book : RecipeBook = $CookingArea/RecipeBook
@onready var order_display : OrderDisplay = $OrderDisplay
@onready var bobo : Bobo = $Bobo

@onready var hands : Array[XRToolsFunctionPickup] = [
	$"XROrigin3D/Left Hand/CollisionHandLeft/FunctionPickup",
	$"XROrigin3D/Right Hand/CollisionHandRight/FunctionPickup"
]

func scene_loaded(user_data = null):
	super(user_data)
	
	# Load level
	_load_level(user_data["level"])
	level_id = user_data["level"]
	
	# Apply level settings
	seed_bags.load_seed_bags(level.active_plants)
	tools.load_tools_bags(level.active_tools)
	
	# Set weed settings
	weed_manager.setup(
		level.spread_time,
		level.spread_indicator_time,
		level.spread_release_grace_time,
		level.spread_chance,
		level.obstacle_spawn_chance
	)
	weed_manager.setup_soil_arrangement(level.soil_setup)
	
	# Set koriko settings
	koriko_manager.setup(level.time_before_first_spawn, level.inital_spawn_chance, level.stack_spawn_chance, level.time_until_death)
	
	# Enable cooking if needed
	if not level.enable_cooking:
		cooking_chest.disable_chest()
		recipe_book.disable_recipe_cook()
	
	# Enable brewing if needed
	if not level.enable_brewing:
		cauldron.disable_cauldron()
	else:
		cauldron.setup(level.drops_per_potion)
	
	# Set order settings
	order_display.setup(level.time_between_orders)
	
	# Setup bobo
	bobo.setup()
	
	# Update return manager
	return_manager.update(true)

func _load_level(level_nr : int) -> void:
	print("Loading ", level_nr)
	
	level = load("res://Levels/Level" + str(level_nr) + ".tscn").instantiate()
	add_child(level)
	
	# Conect level events
	level.completed.connect(_on_level_complete)

func _on_level_complete():
	await get_tree().create_timer(level_complete_fade_offset).timeout
	
	# TODO - Trigger gorgeous confetti effect
	
	# Make sure to let go of all things before loading new scene
	for hand in hands:
		hand.drop_object()
	
	# Load level complete scene
	load_scene("res://Scenes/LevelCompleteScene.tscn", {
		"time" : Statistics.elapsed_time,
		"failed_orders" : Statistics.failed_orders,
		"grown_plants" : Statistics.grown_plants
	}, false)

func level_failed():
	await get_tree().create_timer(level_complete_fade_offset).timeout
	
	# Make sure to let go of all things before loading new scene
	for hand in hands:
		hand.drop_object()
	
	# Load level complete scene
	load_scene("res://Scenes/LevelFailedScene.tscn", {
		"prev_level_id" : level_id,
	}, false)
