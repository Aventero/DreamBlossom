shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D halo_01 : filter_nearest, repeat_enable;
uniform sampler2D halo_02 : filter_nearest;
uniform float object_height;
uniform vec3 base_color : source_color;
uniform vec3 cursor = vec3(0.0, 0.0, 0.0);

varying vec3 position;

void vertex() {
	position = VERTEX;
}

void fragment() {
	vec2 pos = UV * 2.0 + vec2(0.0, -0.05);
	pos.x += TIME * 0.07;
	
	// Reverse direction
	if (position.y <= 0.0001)
	{
		pos.x -= TIME * 0.07;
		pos *= 1.0;
	}
	
	vec3 final = vec3(0.0);
	
	for (int i = 3 ; i >= 0 ; i--)
	{
		vec2 texturePos = pos + float(i) * vec2(0.0, 0.05);
		texturePos.x -= float(i) * TIME * 0.02;
		
		vec3 color = vec3(1.0) * step(0.5, texture(halo_01, texturePos).r);
		final = clamp(final + color, 0.0, 1.0) * 0.7;
	}
	
	ALBEDO = final * base_color;
	ALPHA = final.r * 0.3;
	
	if (position.y >= object_height)
		ALPHA = 0.0;
	
	if (position.y <= 0.0001 && UV.y < 0.7)
		ALPHA = 0.0;
}