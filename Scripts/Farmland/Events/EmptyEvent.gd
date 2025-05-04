extends PlantEvent

func initialize():
	print("CALLED")
	call_deferred("completed")

func completed():
	event_completed.emit()
