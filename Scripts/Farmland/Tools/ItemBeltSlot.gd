class_name ItemBeltSlot
extends PathFollow3D

@export var lerp_duration : float = 0.2

@onready var placeholder : Node3D = $Placeholder
@onready var item_remote_transform : RemoteTransform3D = $Item

var _item : Node3D
var _time : float = 0.0

func _ready():
	set_process(false)
	
	# Scale up placeholder
	placeholder.scale = Vector3.ZERO
	var tween : Tween = create_tween()
	tween.tween_property(placeholder, "scale", Vector3.ONE, 0.1)

func _process(delta):
	_time += delta
	var ratio = min(1, _time / lerp_duration)
	
	# Apply lerped position and transform
	var new_pos : Vector3 = _item.global_position.lerp(global_position, ratio)
	var new_rot : Vector3 = _item.global_rotation.lerp(global_rotation, ratio)
	
	_item.global_position = new_pos
	_item.global_rotation = new_rot
	
	if ratio == 1:
		# Enable remote transform
		item_remote_transform.remote_path = _item.get_path()
		_time = 0
		
		set_process(false)

func set_item(item : XRToolsPickable):
	_item = item
	
	# Disable placeholder
	var tween : Tween = create_tween()
	tween.tween_property(placeholder, "scale", Vector3.ZERO, 0.1)
	tween.tween_callback(func(): placeholder.visible = false)
	
	item.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	item.freeze = true
	item.picked_up.connect(_on_pick_up)
	
	# Start lerping to correct position / rotation
	set_process(true)

func _on_pick_up(item : XRToolsPickable):
	# Enable placeholder
	placeholder.visible = true
	
	var tween : Tween = create_tween()
	tween.tween_property(placeholder, "scale", Vector3.ONE, 0.1)
	
	# Reset remote transform for "free" movement
	item_remote_transform.remote_path = NodePath()
	
	item.picked_up.disconnect(_on_pick_up)

func remove():
	# Disable placeholder
	var tween : Tween = create_tween()
	tween.tween_property(placeholder, "scale", Vector3.ZERO, 0.1)
	tween.tween_callback(queue_free)
