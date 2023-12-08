extends Node3D
class_name Custom_Timer

# Signal is emited when timer reaches zero
signal timeout()

@onready var internal_timer : Timer = $InternalTimer
@onready var time_label : Label = $"TimerUI/Viewport/Timer/MarginContainer/Timer"

var _player : Node3D = null

func _ready():
	_player = get_tree().get_first_node_in_group("Player")

func _process(delta):
	# Handle rotation towards player
	_handle_rotation()
	
	# Handle timer display
	_handle_time_display()

func _handle_rotation():
	# Get angle towards player
	var to_player : Vector3 = _player.position.direction_to(global_position)
	var target_basis = Basis.looking_at(to_player)
	basis = basis.slerp(target_basis, 0.5)

func _handle_time_display():
	if !internal_timer.is_stopped():
		var seconds_left : int = internal_timer.time_left
		var minutes : int = seconds_left / 60
		var seconds : int = seconds_left % 60
		time_label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)

func start_timer(seconds: int):
	internal_timer.wait_time = seconds
	internal_timer.start()

func _on_internal_timer_timeout():
	emit_signal("timeout")
