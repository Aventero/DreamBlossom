@tool
class_name TypeWriter
extends Label
signal text_completed

@export var character_display_time: float = 0.05
@export_tool_button("Start") var display_stuff = show_text

var _full_text: String = ""
var _current_position: int = 0
var _timer: Timer

func _ready() -> void:
	# Create and set up the timer
	_timer = Timer.new()
	add_child(_timer)
	_timer.one_shot = true
	_timer.timeout.connect(_display_next_character)

func show_text():
	display_text("Hey..\n would u mind picking me up? \n or \n not")

func is_displaying() -> bool:
	return _current_position < _full_text.length()

# Start the typing effect with new text
func display_text(new_text: String) -> void:
	_full_text = new_text
	_current_position = 0
	text = ""
	
	_timer.start(character_display_time)

func _display_next_character() -> void:
	if _current_position < _full_text.length():
		text += _full_text[_current_position]
		_current_position += 1
		custom_minimum_size.x = min(800, 100 + _current_position * 20)
		_timer.start(character_display_time)
	else:
		text_completed.emit()

func show_full_text() -> void:
	text = _full_text
	_current_position = _full_text.length()
	_timer.stop()
	text_completed.emit()
