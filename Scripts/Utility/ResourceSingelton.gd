class_name ResourceSingleton
extends ResourcePreloader

static var instance : ResourcePreloader

func _ready():
	instance = self
