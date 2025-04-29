@tool
extends MeshInstance3D

@export var target: Node3D
@export var follow_speed: float = 10.0
@export var min_offset: Vector3 = Vector3(-0.1, -0.1, 0)
@export var max_offset: Vector3 = Vector3(0.1, 0.1, 0)
@export var center_offset: Vector3 = Vector3(0, 0, 0)

# Original position of the pupil (center of eye)
var center_position: Vector3

func _ready():
	# Store the initial position as center point
	center_position = position

func _process(delta):
	if not target:
		return
		
	# Calculate direction to target
	var direction = target.global_position - global_position
	var desired_offset = Vector3(
		direction.x, 
		direction.y, 
		0 
	)
	
	# Clamp the movement within bounds
	desired_offset.x = clamp(desired_offset.x, min_offset.x, max_offset.x)
	desired_offset.y = clamp(desired_offset.y, min_offset.y, max_offset.y)
	
	# Calculate the target position (center + offset)
	var target_position = center_position + desired_offset
	
	# Smoothly move to the target position
	position = target_position
