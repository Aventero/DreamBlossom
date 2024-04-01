shader_type spatial;
render_mode unshaded, cull_disabled;

instance uniform float fill_percentage;

// Model Fill Settings
uniform float min_height;
uniform float max_height;

// Colors
instance uniform vec3 base_color : source_color;
instance uniform vec3 surface_color : source_color;
instance uniform vec3 line_color : source_color;
instance uniform vec3 fresnel_color : source_color;
uniform float line_width = 0.001;

varying vec3 position;

void vertex() {
	position = mat3(MODEL_MATRIX) * VERTEX.xyz;
	
	// Wave
	position.y += 0.0025 * sin(500.0 * position.x + 1.0 * TIME);
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	if (fill_percentage <= 0.0)
		discard;
	
	// Calculate fill percentage
	float fill_line = min_height + (max_height - min_height) * fill_percentage;
	
	if (position.y > fill_line)
		discard;
	
	// Base color
	if (FRONT_FACING)
		ALBEDO = mix(base_color, fresnel_color, fresnel(10.0, NORMAL, VIEW));
	else
		ALBEDO = surface_color;
	
	// Line
	if (position.y > fill_line - line_width)
		ALBEDO = line_color;
}
