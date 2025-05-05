@icon("res://Textures/EditorIcons/Scene.png")
@tool

class_name HubBase
extends XRToolsSceneBase

var pressed : bool = false
static var level_completed: int = 0
static var difficulty: float = 1.0

func scene_loaded(user_data = null):
	super(user_data)
	$ResourcePreloader.reparent(get_node("../.."))

func _process(_delta) -> void:
	if not pressed and Input.is_key_pressed(KEY_0):
		_on_load_scene_button_pressed($"Level Selection/Tutorial/LevelButton")
		pressed = true
		
	show_buttons()
	
func show_buttons() -> void:
	if level_completed == 0:
		$"Level Selection/Tutorial".visible = true
		$"Level Selection/Tutorial".process_mode = Node.PROCESS_MODE_INHERIT
		
		$"Level Selection/DifficultyEasy".visible = false
		$"Level Selection/DifficultyEasy".process_mode = Node.PROCESS_MODE_DISABLED
		$"Level Selection/DifficultyNormal".visible = false
		$"Level Selection/DifficultyNormal".process_mode = Node.PROCESS_MODE_DISABLED
		$"Level Selection/DifficultyHard".visible = false
		$"Level Selection/DifficultyHard".process_mode = Node.PROCESS_MODE_DISABLED
	if level_completed > 0:
		$"Level Selection/DifficultyEasy".visible = true
		$"Level Selection/DifficultyEasy".process_mode = Node.PROCESS_MODE_INHERIT
		$"Level Selection/DifficultyNormal".visible = true
		$"Level Selection/DifficultyNormal".process_mode = Node.PROCESS_MODE_INHERIT
		$"Level Selection/DifficultyHard".visible = true
		$"Level Selection/DifficultyHard".process_mode = Node.PROCESS_MODE_INHERIT
		$"Level Selection/Tutorial".visible = false
		$"Level Selection/Tutorial".process_mode = Node.PROCESS_MODE_DISABLED
		$"Level Selection/Level 1".visible = true
		$"Level Selection/Level 1".process_mode = Node.PROCESS_MODE_INHERIT
	if level_completed > 1:
		$"Level Selection/Level 2".visible = true
		$"Level Selection/Level 2".process_mode = Node.PROCESS_MODE_INHERIT
	if level_completed > 2:
		$"Level Selection/Level 3".visible = true
		$"Level Selection/Level 3".process_mode = Node.PROCESS_MODE_INHERIT
	if level_completed > 3:
		$"Level Selection/Level 4".visible = true
		$"Level Selection/Level 4".process_mode = Node.PROCESS_MODE_INHERIT
	if level_completed > 4:
		$"Level Selection/Level 5".visible = true
		$"Level Selection/Level 5".process_mode = Node.PROCESS_MODE_INHERIT
	if level_completed > 5:
		$"Level Selection/Level 6".visible = true
		$"Level Selection/Level 6".process_mode = Node.PROCESS_MODE_INHERIT

func _input(event: InputEvent) -> void:
	# Check for keyboard input
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var number_pressed = event.keycode - KEY_1 + 1
			level_completed = number_pressed
			print("Number pressed: ", level_completed)

func _on_load_scene_button_pressed(button : LevelButton) -> void:
	load_scene("res://Scenes/IntroScene.tscn", {
		"level": button.level_id
	})

func _on_difficulty_button_button_pressed(button: DifficultyButton) -> void:
	difficulty = button.difficulty_setting
	print("Set difficulty to: ", difficulty)
