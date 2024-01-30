@icon("res://Textures/Bobo.png")
class_name Bobo
extends Node3D

var max_steps : int = 3
var _current_step : int = 0

func _ready():
	LevelManager.get_instance().got_new_quest.connect(Callable(_on_new_quest))
	_current_step = max_steps

func _on_new_quest():
	LevelManager.quest.completed.connect(Callable(_on_quest_completed))
	
func _on_quest_completed(success : bool):
	if success:
		print("BOBO DOESNT DO ANYTHING")
		pass
	else:
		_current_step -= 1
		print("GETTING CLOSER UHIHIHIHIHI")
		if _current_step <= 0:
			print("U DIED")

func _process(delta):
	pass
