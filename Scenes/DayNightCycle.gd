@tool
extends Node3D

var _time_of_day: float = 0.0
@export_range(0, 24, 0.1) var time_of_day: float:
	set(value):
		if Engine.is_editor_hint():
			set_time_of_day(value)
	get:
		return _time_of_day

@export var sky_shader_material: ShaderMaterial

func set_time_of_day(value):
	_time_of_day = value  # Stop unnecissary updates
	update_shader_parameters(value)

	
func calculate_sun_direction(hour: float) -> Vector3:
	# Cycle starts with the sun at its highest at hour = 12
	var angle = TAU * (hour / 24.0)  # TAU is 2*PI
	var sun_direction: Vector3 = Vector3(cos(angle), sin(angle), -0.5)
	return sun_direction	

func calculate_moon_direction(hour: float) -> Vector3:
	var angle = TAU * (hour / 24.0)  # TAU is 2*PI
	var moon_direction: Vector3 = Vector3(cos(angle + PI), sin(angle + PI), -0.5)  # Offset to opposite side
	return moon_direction	

# Is celestial body above the horizon
func is_sky_body_visible(direction: Vector3) -> bool:
	return direction.y > 0

func update_shader_parameters(time_of_day: float) -> void:
	var sun_direction = calculate_sun_direction(time_of_day)
	var moon_direction = calculate_moon_direction(time_of_day)
	sky_shader_material.set_shader_parameter("sun_direction", sun_direction.normalized())
	sky_shader_material.set_shader_parameter("moon_direction", moon_direction.normalized())

	if is_sky_body_visible(sun_direction):
		$Sun.look_at($Sun.global_transform.origin - sun_direction, Vector3.UP)
		$Sun.visible = true
		sky_shader_material.set_shader_parameter("day_intensity", max(sun_direction.y, 0.0))
	else:
		$Sun.visible = false

	if is_sky_body_visible(moon_direction):
		$Moon.look_at($Moon.global_transform.origin - moon_direction, Vector3.UP)
		$Moon.visible = true
		sky_shader_material.set_shader_parameter("night_intensity", max(moon_direction.y, 0.0))
	else:
		$Moon.visible = false
