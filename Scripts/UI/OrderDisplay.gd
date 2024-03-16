class_name OrderDisplay
extends Node3D

@onready var order_display_ui : OrderDisplayUI = $"Order Viewport/Order Display"
@onready var between_timer : Timer = $"Between Orders Timer"

var time_between_orders : float = 1.0

func setup(p_time_between_orders : float) -> void:
	# Set data
	time_between_orders = p_time_between_orders

func start_order():
	# Load first / next order
	if not GameBase.level.next_order():
		return
	
	# Show order
	order_display_ui.start_order()

func _on_order_display_order_completed():
	# Start timer between orders
	between_timer.start(time_between_orders)
