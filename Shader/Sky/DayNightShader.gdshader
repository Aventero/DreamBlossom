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
uniform vec3 sun_color : source_color = vec3(10.0, 8.0, 1.0);
uniform vec3 sun_sunset_color : source_color = vec3(10.0, 0.0, 0.0);
uniform float sun_size : hint_range(0.01, 1.0) = 0.2;
uniform float sun_blur : hint_range(0.01, 20.0) = 10.0;

void sky() {
    float view_angle = abs(sin(EYEDIR.y * PI * 0.5));
    vec3 base_sky_color = mix(day_bottom_color, day_top_color, view_angle);
    
    // Calculate blend factor for under horizon
    float under_horizon_blend = smoothstep(0.0, -0.3, EYEDIR.y);
    vec3 under_horizon_color = mix(under_horizon_top_color, under_horizon_bottom_color,view_angle);

    // Apply blend for bottom sky under the horizon
    base_sky_color = mix(base_sky_color, under_horizon_color, under_horizon_blend);
	
  	// Sunset effect
	vec3 sun_direction = LIGHT0_DIRECTION; // Invert direction for moon
    float sunset_intensity = clamp(0.5 - abs(sun_direction.y), 0.0, 0.5) * 2.0;
    vec3 sunset_color = mix(sunset_bottom_color, sunset_top_color, view_angle);
    base_sky_color = mix(base_sky_color, sunset_color, sunset_intensity);
    
    // Night effect
    float night_intensity = clamp(-sun_direction.y + 0.7, 0.0, 1.0);
    vec3 night_color = mix(night_bottom_color, night_top_color, view_angle);
    vec3 sky_color = mix(base_sky_color, night_color, night_intensity);
    
    // Horizon effect
    float horizon_effect = clamp(-EYEDIR.y / horizon_blur, 0.0, 1.0);
    sky_color = mix(sky_color, mix(horizon_color, sky_color, 0.9), horizon_effect);

	// Sun effect
	if (LIGHT0_ENABLED) {
	    float sun_angle = dot(normalize(EYEDIR), normalize(sun_direction));
	    float sun_visibility = smoothstep(cos(radians(sun_size * 5.0)), 1.0, sun_angle);
	    vec3 sun_effect_color = mix(sun_color, sun_sunset_color, sunset_intensity);
	    sky_color = mix(sky_color, sun_effect_color, sun_visibility * sun_blur);
	}

	vec3 texture_color = texture(skyTexture, SKY_COORDS).rgb;
	COLOR = sky_color + texture_color * (0.8 - night_intensity);
	
	// Maybe add night sky texture
	if (night_intensity > 0.8) {
		COLOR = texture_color * sky_color;
	}
	
}
