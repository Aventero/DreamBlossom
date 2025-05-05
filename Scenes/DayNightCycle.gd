@tool
extends Node3D
class_name DayNightCycle

var _time_of_day: float = 4.0
@export_range(0, 24, 0.01) var time_of_day: float = 0.0:
	set(value):
		set_time_of_day(value)
	get:
		return _time_of_day

@export_range(0.01, 1.0, 0.01) var base_brightness: float = 0.1
@export_range(0.01, 1.0, 0.01) var intro_brightness: float = 1.0
@export var sky_shader_material: ShaderMaterial
@export var world_environment: WorldEnvironment
@export var sun : DirectionalLight3D
@export var moon : DirectionalLight3D
@export var sun_size: float = 0.1
@export var moon_size: float = 0.06

# Add these properties to your class
@export var sunrise_start: float = 6.0  # When sunrise6 begins
@export var sunrise_end: float = 10.0    # When sunrise is complete
@export var sunset_start: float = 15.0  # When sunset begins
@export var sunset_end: float = 19.0    # When sunset is complete
@export var fog_level_view: float = 10.0 

func get_sunrise_factor() -> float:
	# Before sunrise starts
	if time_of_day < sunrise_start:
		return 0.0
	elif time_of_day > sunrise_end:
		return 1.0
	else:
		return (time_of_day - sunrise_start) / (sunrise_end - sunrise_start)

func get_sunset_factor() -> float:
	if time_of_day < sunset_start:
		return 0.0
	elif time_of_day > sunset_end:
		return 1.0
	else:
		return (time_of_day - sunset_start) / (sunset_end - sunset_start)

func get_daylight_factor() -> float:
	# Night before sunrise
	if time_of_day < sunrise_start:
		return 0.0
	# Sunrise transition
	elif time_of_day < sunrise_end:
		return get_sunrise_factor()
	# Full day
	elif time_of_day < sunset_start:
		return 1.0
	# Sunset transition
	elif time_of_day < sunset_end:
		return 1.0 - get_sunset_factor()
	# Night after sunset
	else:
		return 0.0

func set_time_of_day(value):
	_time_of_day = value  # Stop unnecissary updates
	update_shader_parameters(value)

func calculate_sun_direction(hour: float) -> Vector3:
	var shifted_hour = hour - 6.0
	if shifted_hour < 0:
		shifted_hour += 24.0
	
	var angle = TAU * (shifted_hour / 24.0)  # TAU is 2*PI
	var sun_direction: Vector3 = Vector3(cos(angle), sin(angle), -0.5)
	return sun_direction

func calculate_moon_direction(hour: float) -> Vector3:
	var shifted_hour = hour - 6.0
	if shifted_hour < 0:
		shifted_hour += 24.0
		
	var angle = TAU * (shifted_hour / 24.0)  # TAU is 2*PI
	var moon_direction: Vector3 = Vector3(cos(angle + PI), sin(angle + PI), -0.5)
	return moon_direction

# Is celestial body above the horizon
func is_sky_body_visible(direction: Vector3) -> bool:
	return direction.y > 0

func update_shader_parameters(time_day: float) -> void:
	if not sky_shader_material:
		return 
		
	var sun_direction = calculate_sun_direction(time_day)
	var moon_direction = calculate_moon_direction(time_day)
	sky_shader_material.set_shader_parameter("sun_direction", sun_direction.normalized())
	sky_shader_material.set_shader_parameter("moon_direction", moon_direction.normalized())
	sky_shader_material.set_shader_parameter("sun_size", get_daylight_factor() * sun_size)
	sky_shader_material.set_shader_parameter("moon_size", (1.0 - get_daylight_factor()) * moon_size)
	var light_factor = (get_daylight_factor() + -(1.0 - get_daylight_factor()))
	world_environment.environment.fog_depth_end = 12.0 + light_factor * 5.0
	fog_level_view = world_environment.environment.fog_depth_end
	if is_sky_body_visible(sun_direction):
		$Sun.look_at($Sun.global_transform.origin - sun_direction, Vector3.UP)
		$Sun.visible = true
		var power = max(sun_direction.y, base_brightness) * intro_brightness
		sky_shader_material.set_shader_parameter("day_intensity", power)
		sun.light_energy = power
		world_environment.environment.background_energy_multiplier = power
	else:
		$Sun.visible = false

	if is_sky_body_visible(moon_direction):
		$Moon.look_at($Moon.global_transform.origin - moon_direction, Vector3.UP)
		$Moon.visible = true
		var power = max(moon_direction.y, base_brightness) * intro_brightness
		sky_shader_material.set_shader_parameter("night_intensity", max(moon_direction.y, 0.0))
		moon.light_energy = power
		world_environment.environment.background_energy_multiplier = power
	else:
		$Moon.visible = false
