extends Sprite3D

@export var textbox_label: Label

extends Label

signal text_completed

@export var character_display_time: float = 0.05  # Time between characters

var _full_text: String = ""
var _current_position: int = 0
var _timer: Timer

func _ready() -> void:
	# Create and set up the timer
	_timer = Timer.new()
	add_child(_timer)
	_timer.one_shot = true
	_timer.timeout.connect(_display_next_character)

# Start the typing effect with new text
func display_text(new_text: String) -> void:
	# Store the full text
	_full_text = new_text
	
	# Reset current display position
	_current_position = 0
	
	# Clear the label text
	text = ""
	
	# Start displaying characters
	_timer.start(character_display_time)

# Display the next character
func _display_next_character() -> void:
	if _current_position < _full_text.length():
		# Add the next character
		text += _full_text[_current_position]
		_current_position += 1
		
		# Continue timer for next character
		_timer.start(character_display_time)
	else:
		# We've finished displaying all characters
		emit_signal("text_completed")

# Immediately show the full text
func show_full_text() -> void:
	text = _full_text
	_current_position = _full_text.length()
	_timer.stop()
	emit_signal("text_completed")
