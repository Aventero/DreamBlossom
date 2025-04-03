@tool
extends Node3D

var _time_of_day: float = 4.0
@export_range(0, 24, 0.1) var time_of_day: float = 0.0:
	set(value):
		if Engine.is_editor_hint():
			set_time_of_day(value)
	get:
		return _time_of_day

@export var sky_shader_material: ShaderMaterial
@export var world_environment: WorldEnvironment
@export var sun : DirectionalLight3D
@export var moon : DirectionalLight3D

func set_time_of_day(value):
	_time_of_day = value  # Stop unnecissary updates
	update_shader_parameters(value)


func _process(delta: float) -> void:
	# Convert delta to hours (assuming 1 real second = 1 minute in game)
	var time_delta = delta / 20.0
	_time_of_day += time_delta

	if _time_of_day >= 24.0:
		_time_of_day = 0.0

	update_shader_parameters(_time_of_day)

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

func update_shader_parameters(time_day: float) -> void:
	if not sky_shader_material:
		return 
		
	var sun_direction = calculate_sun_direction(time_day)
	var moon_direction = calculate_moon_direction(time_day)
	sky_shader_material.set_shader_parameter("sun_direction", sun_direction.normalized())
	sky_shader_material.set_shader_parameter("moon_direction", moon_direction.normalized())
	if is_sky_body_visible(sun_direction):
		$Sun.look_at($Sun.global_transform.origin - sun_direction, Vector3.UP)
		$Sun.visible = true
		var power = max(sun_direction.y, 0.0)
		sky_shader_material.set_shader_parameter("day_intensity", power)
		sun.light_energy = power
		world_environment.environment.background_energy_multiplier = power
	else:
		$Sun.visible = false

	if is_sky_body_visible(moon_direction):
		$Moon.look_at($Moon.global_transform.origin - moon_direction, Vector3.UP)
		$Moon.visible = true
		var power = max(moon_direction.y, 0.0)
		sky_shader_material.set_shader_parameter("night_intensity", max(moon_direction.y, 0.0))
		moon.light_energy = power
		world_environment.environment.background_energy_multiplier = power
	else:
		$Moon.visible = false
