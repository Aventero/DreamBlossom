@icon("res://Textures/WeedEvent.png")
class_name EventWeed
extends Pullable

var weed_event : WeedEvent = null

func _on_pull_completed():
	weed_event._pulled_weed()
	
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(queue_free)
