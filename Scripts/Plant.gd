@icon("res://Textures/GrowingPlant.png")
extends Node3D

@onready var stage_timer : Timer = $StageTimer
@onready var animation_player : AnimationPlayer = $AnimationPlayer
var stages : Array[Stage] = []
var stage_counter : int = 0

func _ready():
	for child in get_children():
		if child.is_in_group("Stage"):
			stages.append(child)
	
	stage_timer.start(stages[0].run_time)
	animation_player.play(stages[0].animation_name)

func _process(delta):
	pass

func _on_stage_timer_timeout():
	stages[stage_counter].start_event()
	pass


func _on_stage_stage_completed():
	print("STAGE COMPLETED!")
	pass 
