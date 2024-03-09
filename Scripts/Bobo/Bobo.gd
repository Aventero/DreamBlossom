@icon("res://Textures/Bobo/Bobo.png")
class_name Bobo
extends Node3D

var max_steps : int = 3
var _current_step : int = 0

var inital_position : Vector3

func _on_ingredient_trigger_body_entered(ingredient):
	# Check if order is existing and order is currently running
	if not GameBase.level.current_order or GameBase.level.current_order and not GameBase.level.current_order.is_running():
		return
	
	if not ingredient is Ingredient:
		return
	
	# Check if ingredient is still required in order
	if not GameBase.level.current_order.is_required(ingredient.type) or GameBase.level.current_order.get_remaining_amount(ingredient.type) == 0:
		return
	
	# Add ingredient to order
	GameBase.level.current_order.add_to_order(ingredient.type)
	
	# Play eating animation
	_play_eating()
	
	# Despawn ingredient
	ingredient.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	ingredient.freeze = true
	
	var tween : Tween = create_tween()
	tween.tween_property(ingredient, "scale", Vector3.ZERO, 0.5)
	await tween.finished
	
	ingredient.queue_free()

func _play_eating():
	var tween : Tween = create_tween().set_loops(3)
	tween.tween_property($Model/MeshInstance3D11, "scale", Vector3(0.222, 0.1, 0.17), 0.2)
	tween.tween_property($Model/MeshInstance3D11, "scale", Vector3(0.319, 0.075, 0.17), 0.2)

#func _ready():
	#LevelManager.get_instance().got_new_quest.connect(Callable(_on_new_quest))
	#_current_step = max_steps
	#
	#inital_position = position
	#
	## Bobo Jiggle
	#var tween : Tween = create_tween()
	#tween.set_loops()
	#tween.tween_property(self, "position", inital_position + Vector3(0.0, 0.1, 0.0), 1.0)
	#tween.tween_property(self, "position", inital_position + Vector3(0.0, 0.0, 0.0), 1.0)
#
#func _on_new_quest():
	#LevelManager.quest.completed.connect(Callable(_on_quest_completed))
	#
#func _on_quest_completed(success : bool):
	#if success:
		#print("BOBO DOESNT DO ANYTHING")
		#pass
	#else:
		#_current_step -= 1
		#print("GETTING CLOSER UHIHIHIHIHI")
		#if _current_step <= 0:
			#print("U DIED")

