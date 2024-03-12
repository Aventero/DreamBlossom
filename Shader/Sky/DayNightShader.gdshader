shader_type sky;
render_mode use_quarter_res_pass;


// Sky colors
group_uniforms sky;
uniform sampler2D skyTexture : filter_nearest;
uniform sampler2D nightSkyTexture : filter_nearest;
uniform vec3 day_top_color : source_color = vec3(0.1, 0.6, 1.0);
uniform vec3 day_bottom_color : source_color = vec3(0.4, 0.8, 1.0);
uniform vec3 sunset_top_color : source_color = vec3(0.7, 0.75, 1.0);
uniform vec3 sunset_bottom_color : source_color = vec3(1.0, 0.5, 0.7);
uniform vec3 night_top_color : source_color = vec3(0.02, 0.0, 0.04);
uniform vec3 night_bottom_color : source_color = vec3(0.1, 0.0, 0.2);

// Bottom Sky
group_uniforms bottom_sky;
uniform vec3 under_horizon_top_color : source_color = vec3(0.2, 0.4, 0.5);
uniform vec3 under_horizon_bottom_color : source_color = vec3(0.1, 0.2, 0.3);

// Horizon
group_uniforms horizon;
uniform vec3 horizon_color : source_color = vec3(0.0, 0.7, 0.8);
uniform float horizon_blur : hint_range(0.0, 1.0, 0.01) = 0.05;

// Sun
group_uniforms sun;
uniform vec3 sun_direction;
uniform float day_intensity: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform vec3 sun_color : source_color = vec3(10.0, 8.0, 1.0);
uniform vec3 sun_sunset_color : source_color = vec3(10.0, 0.0, 0.0);
uniform float sun_size : hint_range(0.01, 1.0) = 0.2;
uniform float sun_blur : hint_range(0.01, 20.0) = 10.0;

// Moon
group_uniforms moon;
uniform vec3 moon_direction;
uniform float night_intensity: hint_range(0.0, 1.0, 0.1);
uniform vec3 moon_color : source_color = vec3(0.5, 0.6, 0.7);
uniform float moon_size : hint_range(0.01, 1.0) = 0.15;
uniform float moon_blur : hint_range(0.01, 20.0) = 5.0;

// Textures
group_uniforms textures;
uniform sampler2D horizonSkyGradient : filter_linear_mipmap;
uniform sampler2D baseSkyGradient : filter_linear_mipmap;
void sky() {
	vec3 viewDirection = normalize(EYEDIR);
	
	// Angles
	float sunViewDot = dot(sun_direction, viewDirection);
	float skyHeight = sun_direction.y;  // Height of the sun
	float viewHeight = viewDirection.y; 
	float sunMoonDot = dot(sun_direction, moon_direction);
	
	// Dot products go from -1 to 1 -> Normalize
	// -1 = Parallel + opposite
	// 0  = 90°
	//  1 = Parallel
	float sunViewDot01 = (sunViewDot + 1.0) * 0.5;
	float skyHeight01 = (skyHeight + 1.0) * 0.5;
	
    // Sample sky texture based on elevation
    vec3 baseSkyColor = texture(baseSkyGradient, vec2(skyHeight01, 0.5)).rgb;
	vec3 horizonColor = texture(horizonSkyGradient, vec2(skyHeight01, 0.5)).rgb;
	float horizonMix = pow(1.0 - viewHeight, 4.0);
	COLOR = baseSkyColor + horizonMix * horizonColor;
	
    //float view_angle = abs(sin(EYEDIR.y * PI * 0.5));
    //vec3 base_sky_color = mix(day_bottom_color, day_top_color, view_angle);
    //
    //// Calculate blend factor for under horizon
    //float under_horizon_blend = smoothstep(0.0, -0.3, EYEDIR.y);
    //vec3 under_horizon_color = mix(under_horizon_top_color, under_horizon_bottom_color,view_angle);
//
    //// Apply blend for bottom sky under the horizon
    //base_sky_color = mix(base_sky_color, under_horizon_color, under_horizon_blend);
    //vec3 sky_color;
//
	//// Sunset effect
    //float sunset_intensity = clamp(0.5 - abs(sun_direction.y), 0.0, 0.5) * 2.0;
    //vec3 sunset_color = mix(sunset_bottom_color, sunset_top_color, view_angle);
    //base_sky_color = mix(base_sky_color, sunset_color, sunset_intensity);
	//
    //// Horizon effect
    //float horizon_effect = clamp(-EYEDIR.y / horizon_blur, 0.0, 1.0);
    //sky_color = mix(sky_color, mix(horizon_color, sky_color, 0.9), horizon_effect);
    //float sun_angle = dot(normalize(EYEDIR), normalize(sun_direction));
    //float sun_visibility = smoothstep(cos(radians(sun_size * 5.0)), 1.0, sun_angle);
    //vec3 sun_effect_color = mix(sun_color, sun_sunset_color, sunset_intensity);
    //sky_color = mix(sky_color, sun_effect_color, sun_visibility * sun_blur);
//
	//// Moon effect
    //vec3 night_color = mix(night_bottom_color, night_top_color, view_angle);
	//sky_color = mix(base_sky_color, night_color, night_intensity);
    //float moon_angle = dot(normalize(EYEDIR), normalize(moon_direction));
    //float moon_visibility = smoothstep(cos(radians(moon_size * 5.0)), 1.0, moon_angle);
    //vec3 moon_effect_color = moon_color;
    //sky_color = mix(sky_color, moon_effect_color, moon_visibility * moon_blur);
//
	//vec3 texture_color = texture(skyTexture, SKY_COORDS).rgb;
	//COLOR = sky_color * texture_color;
	
}
