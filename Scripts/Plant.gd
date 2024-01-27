@icon("res://Textures/GrowingPlant.png")
class_name Plant
extends Node3D
 
@onready var stage_timer : Timer = $StageTimer
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@export var plant_model : Node3D
@export var death_material : Material

signal dying

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
	else:
		_die()

func request_tween(force : bool = false) -> Tween:
	if not tween or force or not tween.is_valid():
		if tween:
			tween.kill()
		
		tween = create_tween()
		return tween
	
	return null

func _die():
	dying.emit()
	# change material to the one thats exported 
	assign_material_to_all_meshes(plant_model, death_material)
	
	# Quickly Play the animation backwards
	animation_player.speed_scale = 10
	animation_player.play_backwards()

func assign_material_to_all_meshes(node : Node3D, material_to_assign : Material):
	
	# Set the material on each mesh
	for child in node.get_children():
		if child is MeshInstance3D:
			child.material_override = material_to_assign
		assign_material_to_all_meshes(child, material_to_assign)

func _on_animation_player_animation_finished(anim_name):
	
	# Die once the animation is back at the start
	DigSpotLookup.get_dig_spot(self).remove_self()
