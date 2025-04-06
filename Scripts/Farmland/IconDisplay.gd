class_name IconDisplay
extends MeshInstance3D

@onready var viewport : SubViewport = $"../IconViewport"
@onready var icon_rect : TextureRect = $"../IconViewport/Icon"

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
	
	# Set new render texture to icon
	icon_rect.texture = icon
	
	# Update viewport once
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	# Set viewport texture as override
	var material_dup : StandardMaterial3D = mesh.surface_get_material(0).duplicate()
	material_dup.albedo_texture = viewport.get_texture()
	material_override = material_dup
	
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
