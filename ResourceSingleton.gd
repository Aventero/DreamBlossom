class_name ResourceSingleton
extends ResourcePreloader

static var instance : ResourceSingleton

func _ready():
	# Setup Singelton
	if instance == null:
		instance = self
	else:
		queue_free()
