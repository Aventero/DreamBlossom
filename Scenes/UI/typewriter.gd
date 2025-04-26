@tool
class_name TypeWriter
extends Label
signal text_completed

@export var blossy_visible_on_screen_notifier: VisibleOnScreenNotifier3D
@export var character_display_time: float = 0.05
@export var timer: Timer
@export_tool_button("Start") var display_stuff = show_text

var _full_text: String = ""
var _current_position: int = 0
var _paused: bool = false

func _ready() -> void:
	if blossy_visible_on_screen_notifier:
		blossy_visible_on_screen_notifier.screen_entered.connect(_on_blossy_visible)
		blossy_visible_on_screen_notifier.screen_exited.connect(_on_blossy_not_visible)
	
	if timer:
		timer.one_shot = true
		timer.timeout.connect(_display_next_character)

func show_text():
	display_text("Hey..\n would u mind picking me up? \n or \n not")

func is_displaying() -> bool:
	return _current_position < _full_text.length()

# Start the typing effect with new text
func display_text(new_text: String) -> void:
	_full_text = new_text
	_current_position = 0
	text = ""
	
	if not _paused:
		timer.start(character_display_time)

func _display_next_character() -> void:
	if _current_position < _full_text.length():
		text += _full_text[_current_position]
		_current_position += 1
		custom_minimum_size.x = min(800, 100 + _current_position * 20)
		timer.start(character_display_time)
		
		if not _paused:
			timer.start(character_display_time)
	else:
		text_completed.emit()

func show_full_text() -> void:
	text = _full_text
	_current_position = _full_text.length()
	timer.stop()
	text_completed.emit()

# Pause the text display
func pause() -> void:
	if is_displaying():
		_paused = true
		timer.stop()

# Resume the text display
func resume() -> void:
	if is_displaying() and _paused:
		_paused = false
		timer.start(character_display_time)

# Connected to screen_entered signal
func _on_blossy_visible() -> void:
	print("BLOSSY VISIBLE")
	resume()
	
# Connected to screen_exited signal
func _on_blossy_not_visible() -> void:
	print("BLOSSY NOT VISIBLE")
	pause()
