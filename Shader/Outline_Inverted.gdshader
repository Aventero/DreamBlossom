shader_type spatial;
render_mode unshaded, cull_front;

uniform vec3 base_color : source_color;
uniform float color_difference = 1.0;
uniform float speed = 1.0;

uniform sampler2D mask : filter_nearest;

void fragment() {
	if (texture(mask, UV).a > 0.0)
		ALBEDO = base_color * ((sin(TIME * speed) * color_difference / 2.0) + 0.5);
	else
		ALPHA = 0.0;
}