class_name GameBase
extends XRToolsSceneBase

static var level : Level

@onready var seed_bags : SeedBagsEnabler = $"ToolArea/Seed Bags"
@onready var tools : ToolsEnabler = $"ToolArea/Variable Tools"
@onready var weed_manager : WeedManager = $Managers/WeedManager
@onready var return_manager : ReturnManager = $Managers/ReturnManager
@onready var koriko_manager : KorikoManager = $Managers/KorikoManager
@onready var cooking_chest : CookingChest = $CookingArea/CookingChest
@onready var recipe_book : RecipeBook = $CookingArea/RecipeBook
@onready var order_display : OrderDisplay = $OrderDisplay

func scene_loaded(user_data = null):
	super(user_data)
	
	# Load level
	if user_data and user_data["level"]:
		_load_level(user_data["level"])
	else:
		_load_level(1)
	
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
	if not level.enable_cooking_chest:
		cooking_chest.disable_chest()
		recipe_book.disable_recipe_cook()
	
	# Set order settings
	order_display.setup(level.time_between_orders)
	
	# Update return manager	
	return_manager.update(true)

func _load_level(level_nr : int) -> void:
	level = load("res://Levels/Level" + str(level_nr) + ".tscn").instantiate()
	add_child(level)
	
	# Conect level events
	level.completed.connect(_on_level_complete)

func _on_level_complete():
	print("Well done! Level completed :D")
