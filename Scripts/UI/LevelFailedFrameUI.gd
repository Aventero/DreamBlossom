class_name LevelFailedFrameUI
extends Panel

@onready var hint : Label = $Center/VBoxContainer/Hint

var _hints : Array[String] = [
	"Dont give up just yet",
	"There are more things to do",
	"Not dead yet",
	"Stand up",
	"They are watching you"
]

func _ready() -> void:
	# Set random hint from array
	hint.text = _hints.pick_random()
