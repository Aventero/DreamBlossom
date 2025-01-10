shader_type sky;
render_mode use_quarter_res_pass;

// Sky colors
group_uniforms sky;
uniform sampler2D nightSkyTexture : filter_nearest;
uniform sampler2D cloudsTexture : filter_nearest;
uniform sampler2D horizonSkyGradient : filter_linear_mipmap;
uniform sampler2D baseSkyGradient : filter_linear_mipmap;
uniform vec3 day_sky_color : source_color = vec3(1.0, 1.0, 1.0);

// Sun
group_uniforms sun;
uniform vec3 sun_direction;
uniform float day_intensity: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform vec3 sun_color : source_color = vec3(10.0, 8.0, 1.0);
uniform float sun_size : hint_range(0.01, 1.0) = 0.2;


// Moon
group_uniforms moon;
uniform vec3 moon_direction;
uniform float night_intensity: hint_range(0.0, 1.0, 0.1);
uniform vec3 moon_color : source_color = vec3(0.5, 0.6, 0.7);
uniform float moon_size : hint_range(0.01, 1.0) = 0.05;

float getSunMask(float sunViewDot, float sunRadius) {
	float stepRadius = 1.0 - sunRadius * sunRadius;
	return smoothstep(stepRadius, stepRadius * 1.1, sunViewDot);
}

void sky() {
	vec3 viewDirection = normalize(EYEDIR);
	
	// Angles
	float sunViewDot = dot(sun_direction, viewDirection); // Used for Sun Mask
	float moonViewDot = dot(moon_direction, viewDirection); // Used for Moon Mask
	float sunHeight = sun_direction.y;  // Used for the Base Sky Color
	float viewHeight = viewDirection.y; // Used for the Horizon

	// Normalized Dot Products (0 - 1)
	float sunViewDot01 = (sunViewDot + 1.0) * 0.5;
	float sunHeight01 = (sunHeight + 1.0) * 0.5;
	
    vec3 baseSkyColor = texture(baseSkyGradient, vec2(sunHeight01, 0.5)).rgb * 0.8;
	vec3 horizonColor = texture(horizonSkyGradient, vec2(sunHeight01, 0.5)).rgb * 0.7;
	float horizonMix = pow(1.0 - abs(1.0 * viewHeight), 4.0);
	vec3 skyColor = baseSkyColor + horizonColor * horizonMix;
	
	// Drawing Sun
	float sunMask = getSunMask(sunViewDot, sun_size);
	vec3 _sunColor = sun_color * sunMask;
	
	// Drawing Moon
	float moonMask = getSunMask(moonViewDot, moon_size);
	vec3 _moonColor = moon_color * moonMask;
	
	vec3 cloudTextureColor = texture(cloudsTexture, SKY_COORDS).rgb * day_sky_color;
	if (day_intensity > 0.001) {
		skyColor = mix(skyColor, cloudTextureColor, pow(clamp(0.0, 1.0, sunHeight), 4.0));
	} else {
		vec3 nightSky = texture(nightSkyTexture, SKY_COORDS).rgb;
		skyColor = mix(skyColor, nightSky, pow(abs((sunHeight - 1.0) * 0.5), 4.0)) * abs(1.2 - night_intensity);
	}
	skyColor += _sunColor + _moonColor;
	COLOR = skyColor;
	
}
