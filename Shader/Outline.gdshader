shader_type spatial;
render_mode unshaded;

uniform vec3 base_color : source_color;
uniform float color_difference = 1.0;
uniform float speed = 1.0;

void fragment() {
	ALBEDO = base_color * ((sin(TIME * speed) * color_difference / 2.0) + 0.5);
}