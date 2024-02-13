shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D noise : filter_nearest;

uniform float pow_strength = 10;
uniform float effect_strength = 1.0;
uniform vec3 effect_color : source_color;
uniform vec3 highlight_color : source_color;
uniform float object_height = 0.0;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform float uv1_blend_sharpness;
varying vec3 uv1_triplanar_pos;
varying vec3 uv1_power_normal;

varying float height;
varying vec3 position;

void vertex() {
	height = VERTEX.y + object_height;
	position = VERTEX.xyz;
	vec3 normal = MODEL_NORMAL_MATRIX * NORMAL;
	uv1_power_normal=pow(abs(normal),vec3(uv1_blend_sharpness));
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0f)).xyz * uv1_scale + uv1_offset;
}

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

void fragment() {
	vec2 pos = UV * 2.0;
	
	// Movement
	vec3 final_color = vec3(1.0);
	for (int i = 1 ; i < 17; i++)
	{
		vec3 offset = vec3(TIME * hash11(float(i)) * mod(float(i), 3), -TIME * hash11(float(i)), TIME * hash11(float(i) * mod(float(i), 3))) / 4.0;
		
		float value = triplanar_texture(noise, uv1_power_normal, uv1_triplanar_pos + offset).r;
		
		final_color = mix(final_color, vec3(1.0) * step(0.5, value), 0.5);
	}
	
	// Fade
	ALPHA = pow(2.7, -pow_strength * height) * effect_strength * step(0.00001, height);
	ALBEDO = effect_color + final_color * highlight_color;
}
