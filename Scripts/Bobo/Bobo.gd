@icon("res://Textures/Bobo.png")
class_name Bobo
extends Node3D

var max_steps : int = 3
var _current_step : int = 0

var inital_position : Vector3

func _ready():
	LevelManager.get_instance().got_new_quest.connect(Callable(_on_new_quest))
	_current_step = max_steps
	
	inital_position = position
	
	# Bobo Jiggle
	var tween : Tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position", inital_position + Vector3(0.0, 0.1, 0.0), 1.0)
	tween.tween_property(self, "position", inital_position + Vector3(0.0, 0.0, 0.0), 1.0)

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
