class_name LevelCompleteFrameUI
extends Panel

@onready var time_label : Label = $Center/VBoxContainer/Statistics/Time
@onready var failed_orders_label : Label = $"Center/VBoxContainer/Statistics/Failed Orders"
@onready var grown_plants_label : Label = $"Center/VBoxContainer/Statistics/Grown Plants"

func set_data(time : float, failed_orders : int, grown_plants : int) -> void:
	# Set elasped time
	var minutes : int = int(time) / 60
	var seconds : int = int(time) % 60
	time_label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
	
	# Set additional data
	failed_orders_label.text = str(failed_orders)
	grown_plants_label.text = str(grown_plants)
