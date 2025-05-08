@icon("res://Textures/EditorIcons/Scene.png")
@tool

class_name HubBase
extends XRToolsSceneBase

var pressed : bool = false
static var level_completed: int = 0
static var difficulty: float = 1.0
static var manual_head_offset: float = 0

func scene_loaded(user_data = null):
	super(user_data)
	$ResourcePreloader.reparent(get_node("../.."))

func _process(_delta) -> void:
	if not pressed and Input.is_key_pressed(KEY_0):
		_on_load_scene_button_pressed($"Level Selection/Tutorial/LevelButton")
		pressed = true
		
	show_buttons()

func show_buttons() -> void:
	for i in range(1, 7):
		show_level_x(i, false)
	
	if level_completed == 0:
		$"Level Selection/Tutorial".visible = true
		$"Level Selection/Tutorial".process_mode = Node.PROCESS_MODE_INHERIT
		# Difficulty off
		$"Level Selection/DifficultyEasy".visible = false
		$"Level Selection/DifficultyEasy".process_mode = Node.PROCESS_MODE_DISABLED
		$"Level Selection/DifficultyNormal".visible = false
		$"Level Selection/DifficultyNormal".process_mode = Node.PROCESS_MODE_DISABLED
		$"Level Selection/DifficultyHard".visible = false
		$"Level Selection/DifficultyHard".process_mode = Node.PROCESS_MODE_DISABLED
	if level_completed > 0:
		show_level_x(1, true)
		
		$"Level Selection/Tutorial".visible = false
		$"Level Selection/Tutorial".process_mode = Node.PROCESS_MODE_DISABLED
		
		# Difficulty on
		$"Level Selection/DifficultyEasy".visible = true
		$"Level Selection/DifficultyEasy".process_mode = Node.PROCESS_MODE_INHERIT
		$"Level Selection/DifficultyNormal".visible = true
		$"Level Selection/DifficultyNormal".process_mode = Node.PROCESS_MODE_INHERIT
		$"Level Selection/DifficultyHard".visible = true
		$"Level Selection/DifficultyHard".process_mode = Node.PROCESS_MODE_INHERIT
	if level_completed > 1:
		show_level_x(2, true)
	if level_completed > 2:
		show_level_x(3, true)
	if level_completed > 3:
		show_level_x(4, true)
	if level_completed > 4:
		show_level_x(5, true)
	
	if level_completed > 0:
		show_level_x(6, true)


func show_level_x(level: int, show: bool = true):
		var level_node = get_node("Level Selection/Level " + str(level))
		level_node.visible = show
		if show:
			level_node.process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	# Check for keyboard input
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var number_pressed = event.keycode - KEY_1 + 1
			level_completed = number_pressed
		if event.keycode == KEY_PLUS:
			manual_head_offset += 0.05
		if event.keycode == KEY_MINUS:
			manual_head_offset -= 0.05

func _on_load_scene_button_pressed(button : LevelButton) -> void:
	print("load:", button.level_id)
	if button.level_id == 0:
		load_scene("res://Scenes/IntroScene.tscn", {
			"level": button.level_id
		})
	else:
		load_scene("res://Scenes/GameScene.tscn", {
			"level": button.level_id
		})

func _on_difficulty_button_button_pressed(button: DifficultyButton) -> void:
	difficulty = button.difficulty_setting
	print("Set difficulty to: ", difficulty)
