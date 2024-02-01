class_name InactivityManager
extends Timer

@export var inactivity_time : float = 10

func _ready():
	timeout.connect(Callable(_on_timeout))
	
	# Subscribe to pickup event of current pickable object
	self.owner.picked_up.connect(Callable(_on_object_pick_up))
	self.owner.dropped.connect(Callable(_on_object_dropped))
	
	# Setup and start timer
	start(inactivity_time)

func _on_object_pick_up(pickable : XRToolsPickable):
	# Stop timer
	stop()

func _on_object_dropped(pickable : XRToolsPickable):
	# Start timer again
	start(inactivity_time)

func _on_timeout():
	# Destory object
	var tween : Tween = create_tween()
	tween.tween_property(self.owner, "scale", Vector3.ZERO, 0.5)
	tween.tween_callback(Callable(_destroy_callback))

func _destroy_callback():
	self.owner.queue_free()
