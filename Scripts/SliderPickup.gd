extends Node3D

@onready var slider = $"../Slidable"
@onready var slide_pickup = $SliderPickup
@onready var leftStop = $"../LeftStop"
@onready var rightStop = $"../RightStop"

@export var drop_distance : float = 1

var slider_grabbed : bool = false
var slider_start_position : Vector3
var slider_half_size : float = 0

func _ready():
	slider_half_size = slider.get_aabb().size.y / 2 * slider.scale.y


func _process(delta):
	if (slider_grabbed):
		var current_slider_position : Vector3 = to_local(slide_pickup.global_position)
		
		# Calculate distance on x Axis between two coordinates
		var distance : float = current_slider_position.x - to_local(slider_start_position).x
		
		var preferred_slider_position : Vector3 = slider_start_position - Vector3(distance, 0, 0)
		
		# Limit slider range
		preferred_slider_position.x = min(preferred_slider_position.x, leftStop.global_position.x - slider_half_size)
		preferred_slider_position.x = max(preferred_slider_position.x, rightStop.global_position.x + slider_half_size)
		
		# Set new slider position
		slider.global_position = preferred_slider_position
		
		# Check distance to slider
		var distance_to_slider : float = slider.global_position.distance_to(slide_pickup.global_position)
		
		if (distance_to_slider > drop_distance):
			slide_pickup.drop()


func _on_pickup_picked_up(pickable):
	print("Slider picked up")
	slider_grabbed = true
	
	# Save slide start position
	slider_start_position = slider.global_position
	
	print("Start slider: " + str(slider.global_position))


func _on_pickup_dropped(pickable):
	print("Slider dropped")
	slider_grabbed = false
	
	# Reset position to slidable
	slide_pickup.global_position = slider.global_position
