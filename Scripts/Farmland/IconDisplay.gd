class_name IconDisplay
extends Sprite3D

var original_scale : Vector3
@onready var player_camera : XRCamera3D = get_viewport().get_camera_3d()

func _ready():
	original_scale = scale

func _process(_delta):
	look_at(player_camera.global_position, Vector3.UP)
	rotation = Vector3(PI / 2.0, rotation.y + PI, 0.0)

func show_icon(icon : Texture2D, icon_position : Vector3):
	set_process(true)
	
	position = icon_position
	visible = true
	scale = Vector3(0.001, 0.001, 0.001)
	
	# Set viewport texture as override
	texture = icon
	
	# Tween to correct size
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", original_scale, 0.2)

func hide_icon():
	# Tween to correct size
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.001, 0.001, 0.001), 0.2)
	tween.tween_callback(Callable(_tween_callback_hide))

func _tween_callback_hide():
	visible = false
	set_process(false)
