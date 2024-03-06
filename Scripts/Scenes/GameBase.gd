class_name Game
extends XRToolsSceneBase

static var Level : Level

@onready var seed_bags : LevelActivationManager = $"Seed Bags"
#@onready var tools : LevelActivationManager = $Tools
@onready var weed_manager : WeedManager = $WeedManager
@onready var return_manager : ReturnManager = $ReturnManager

func scene_loaded(user_data = null):
	super(user_data)
	
	# Load level
	_load_level(user_data["level"])
	
	# Apply level settings
	seed_bags.load_objects(Level.active_plants)
	#tools.enable_objects(Level.active_tools)
	weed_manager.set_level_data(Level.inital_weed_chance, Level.additional_weed_chance, Level.spread_time, Level.spread_chance)
	
	# Gather data for return manager
	return_manager.get_data()

func _load_level(level : int):
	Level = load("res://Levels/Level" + str(level) + ".tscn").instantiate()
	add_child(Level)
	
	# Connect level completed event
	Level.completed.connect(on_level_completed)

func on_level_completed():
	print("Well done! Level completed")
