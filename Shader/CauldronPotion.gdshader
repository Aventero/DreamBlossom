shader_type spatial;

uniform vec3 base_color : source_color;
uniform float alpha;

// Noise
uniform sampler2D potion_noise : filter_nearest;
uniform float mix_amount = 0.5;

void vertex() {
	// Wave
	VERTEX.y += 0.004 * sin(30.0 * VERTEX.x + 4.0 * TIME + VERTEX.z * 2.0 * TIME);
}

void fragment() {
	ALPHA = alpha;
	
	vec3 noise_color = texture(potion_noise, UV * 10.0 + vec2(0.02 * sin(TIME), 0.01 * sin(TIME))).rgb;
	ALBEDO = mix(base_color, base_color * noise_color, mix_amount);
}