@icon("res://Textures/GrowingPlant.png")
class_name Plant
extends Node3D
 
@onready var stage_timer : Timer = $StageTimer
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var stages : Array[Stage] = []
var current_stage : int = 0

var tween : Tween

func _ready():
	# Search for stages in plant
	for child in get_children():
		if child.is_in_group("Stage"):
			stages.append(child)
	
	# Start first stage
	start_stage(current_stage)

func start_stage(index : int):
	var stage : Stage = stages[index]
	
	if stage.should_play_animation:
		# Play the animation
		stage_timer.start(stage.animation_time)
		animation_player.play(stage.animation_name)
	else:
		# Start events immediatly
		stages[current_stage].start_events()

func _on_stage_timer_timeout():
	if animation_player.is_playing():
		animation_player.pause()
	
	# Start stage events
	stages[current_stage].start_events()

func _on_stage_complete():
	print("STAGE COMPLETED!")
	current_stage += 1
	if current_stage < stages.size():
		start_stage(current_stage)

func request_tween(force : bool = false) -> Tween:
	if not tween or force or not tween.is_valid():
		if tween:
			tween.kill()
		
		tween = create_tween()
		return tween
	
	return null
