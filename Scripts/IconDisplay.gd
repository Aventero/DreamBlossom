class_name IconDisplay
extends MeshInstance3D

@onready var viewport : SubViewport = $"../IconViewport"
@onready var icon_rect : TextureRect = $"../IconViewport/Icon"

var original_scale : Vector3

func _ready():
	original_scale = scale

func show_icon(icon : Texture2D):
	visible = true
	scale = Vector3.ZERO
	
	# Set new render texture to icon
	icon_rect.texture = icon
	
	# Update viewport once
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ONCE)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	# Set viewport texture as override
	material_override.albedo_texture = viewport.get_texture()
	
	# Tween to correct size
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", original_scale, 0.2)

func hide_icon():
	# Tween to correct size
	var tween : Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(Callable(_tween_callback_hide))

func _tween_callback_hide():
	visible = false
