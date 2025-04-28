extends Node3D

@export_group("Node References")
@export var pickable: XRToolsPickable
@export var type_writer: TypeWriter
@export var pickup_sprite_animation: AnimatedSprite2D
@export var squish_sprite_animation: AnimatedSprite2D
@export var something_behind_notifier: VisibleOnScreenNotifier3D
@export var bobo_appears_notifier: VisibleOnScreenNotifier3D
@export var bobo_follower: BoboFollower
@export var bobo: Bobo
@export var plot: Node3D
@export var order_view: Node3D
@export var shield: Node3D
@export var grid: PlantGrid
@export var spawn_digpot: PackedScene
@export var blubburu: PackedScene

@export_group("Messaging")
@export_multiline var initial_text: String
@export_multiline var pickup_message: String
@export_multiline var dropped_message: String
@export_multiline var squish_messages: Array[String]

@export_group("Event")
@export var event_name_at: Dictionary[int, String]
var current_message_pos: int = 0
var is_squish_blocked: bool
var current_event: String
var is_done_polling: bool = false
var is_event_completed: bool = false

func _ready() -> void:

	

	# signals	
	pickable.action_pressed.connect(_on_squish)
	pickable.picked_up.connect(_on_picked_up)
	pickable.dropped.connect(_on_dropped)
	type_writer.display_text(initial_text)
	pickup_sprite_animation.visible = true
	
func _on_squish(_pickable):
	# Just always hide after squishing
	squish_sprite_animation.visible = false 
	if is_squish_blocked:
		return
	
	# Start the event
	if current_message_pos in event_name_at:
		event_start(event_name_at[current_message_pos])
	
	# double press shows full text
	if type_writer.is_displaying():
		type_writer.show_full_text()
	else:
		type_writer.display_text(squish_messages[current_message_pos])
		current_message_pos += 1
		
func _on_picked_up(_pickable):
	# Grid cell things
	var current_cell : GridCell = grid.get_cell_by_index(19)
	current_cell.grid.set_state(current_cell, 2, GridCell.CELLSTATE.OCCUPIED)
	var current_cell_pos = grid.get_placement_position(current_cell, 2)

	# Spawn dig spot
	var dig_spot_instance: DigSpot = spawn_digpot.instantiate()
	$"..".add_child(dig_spot_instance)
	dig_spot_instance.global_position = current_cell_pos
	dig_spot_instance.anchor_cell = current_cell
	dig_spot_instance._spawn_plant_no_seed("TutorialBlubburuPlant")
	
	# Has to learn squishing (first pick up)
	if current_message_pos == 0:
		type_writer.display_text(pickup_message)
		squish_sprite_animation.visible = true
		return
	
	# Otherwise display current (previous) text again
	pickup_sprite_animation.visible = false
	type_writer.display_text(squish_messages[current_message_pos - 1])
	type_writer.show_full_text()
	
func _on_dropped(_pickable):
	pickup_sprite_animation.visible = true
	type_writer.display_text(dropped_message)

func _process(_delta: float) -> void:
	if is_event_completed:
		event_end(current_event)

	if is_done_polling:
		return
	
	is_done_polling = event_polling(current_event)

func event_start(event_name: String) -> void:
	current_event = event_name
	is_squish_blocked = true
	is_event_completed = false
	is_done_polling = false

func event_polling(event_name: String) -> bool:
	if event_name == "look_behind":
		if something_behind_notifier.is_on_screen():
			plot.visible = true
			order_view.visible = true
			shield.visible = true
			type_writer.display_text("Oh.. it was just the tree")
			something_behind_notifier.visible = false
			is_squish_blocked = false
			is_event_completed = true
			return true
			
	if event_name == "bobo_appears":
		if bobo_appears_notifier.is_on_screen():
			is_squish_blocked = true
			type_writer.display_text("What is that creature.")
			bobo_follower.move_bobo(0.5, 1.0)
			return true 
			
	return false

func event_end(_event_name: String) -> void:
	is_squish_blocked = false
	current_event = "none"
	
func _on_bobo_path_follow_3d_bobo_done_moving() -> void:
	if current_event == "bobo_appears":
		is_event_completed = true
		bobo.sit_down()
