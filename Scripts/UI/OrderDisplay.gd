class_name OrderDisplay
extends Node3D

@onready var order_display_ui : OrderDisplayUI = $"Order Viewport/Order Display"
var time_between_orders : float = 1.0

func start_order():
	# Load first / next order
	if not GameBase.level.next_order():
		return
	
	# Show order
	order_display_ui.start_order()


func _on_order_display_order_completed() -> void:
	$Success.play()
