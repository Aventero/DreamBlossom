class_name GameBase
extends XRToolsSceneBase

static var level : Level

@onready var seed_bags : SeedBagsEnabler = $"ToolArea/Seed Bags"
@onready var tools : ToolsEnabler = $"ToolArea/Variable Tools"
@onready var weed_manager : WeedManager = $Managers/WeedManager
@onready var return_manager : ReturnManager = $Managers/ReturnManager

func scene_loaded(user_data = null):
	super(user_data)
	
	# Load level
	_load_level(user_data["level"])
	
	# Apply level settings
	seed_bags.load_seed_bags(level.active_plants)
	tools.load_tools_bags(level.active_tools)
	
	# Set weed settings
	weed_manager.inital_weed_chance = level.inital_weed_chance
	weed_manager.additional_weed_chance = level.additional_weed_chance
	weed_manager.setup_soil_arrangement(level.soil_setup)
	
	# Update return manager
	return_manager.update(true)

func _load_level(level_nr : int) -> void:
	level = load("res://Levels/Level" + str(level_nr) + ".tscn").instantiate()
	add_child(level)
	
	# Conect level events
	level.completed.connect(_on_level_complete)

func _on_level_complete():
	print("Well done! Level completed :D")
