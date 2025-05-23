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
@export var shield: Node3D
@export var grid: PlantGrid
@export var spawn_digpot: PackedScene
@export var blubburu: PackedScene
@export var order_display: OrderDisplay
@export var tool_area: Node3D
@export var blossy: Blossy
@export var day_cycle_manager: DayCycleManager

@export_group("Messaging")
@export_multiline var initial_text: String
@export_multiline var pickup_message: String
@export_multiline var pickup_message_respawn: String
@export_multiline var dropped_message: String
@export_multiline var dropped_message_respawn: String
@export_multiline var squish_messages: Array[String]
@export_multiline var squish_messages_respawn: Array[String]

@export_group("Event")
@export var event_name_at: Dictionary[int, String]
var current_message_pos: int = 0
var is_squish_blocked: bool
var current_event: String
var is_done_polling: bool = false
var is_event_completed: bool = false

func _ready() -> void:
	pickable.action_pressed.connect(_on_squish)
	pickable.picked_up.connect(_on_picked_up)
	pickable.dropped.connect(_on_dropped)
	type_writer.display_text(initial_text)
	pickup_sprite_animation.visible = true
	
func _on_squish(_pickable):
	if blossy.can_respawn:
		type_writer.display_text(squish_messages_respawn[current_message_pos])
		if current_message_pos < squish_messages_respawn.size(): 
			current_message_pos += 1
		return
	
	# Just always hide after squishing
	squish_sprite_animation.visible = false 
	if is_squish_blocked:
		return
	
	# Start the event
	if current_message_pos in event_name_at:
		event_start(event_name_at[current_message_pos])
	
	type_writer.display_text(squish_messages[current_message_pos])
	if current_message_pos < squish_messages.size(): 
		current_message_pos += 1
		
func _on_picked_up(_pickable):
	if blossy.can_respawn:
		# Do other dialog
		current_message_pos = 0
		type_writer.display_text(pickup_message)
		return

	# Has to learn squishing (first pick up)
	if current_message_pos == 0:
		type_writer.display_text(pickup_message)
		squish_sprite_animation.visible = true
		pickup_sprite_animation.visible = false
		return
	
	# Otherwise display current (previous) text again
	pickup_sprite_animation.visible = false
	type_writer.display_text(squish_messages[current_message_pos - 1])
	type_writer.show_full_text()

func spawn_dig_spot_with_plant(plant_name: String) -> void:
	# Spawn dig spot
	var current_cell : GridCell = grid.get_cell_by_index(19)
	current_cell.grid.set_state(current_cell, 2, GridCell.CELLSTATE.OCCUPIED)
	var current_cell_pos = grid.get_placement_position(current_cell, 2)
	var dig_spot_instance: DigSpot = spawn_digpot.instantiate()
	$"..".add_child(dig_spot_instance)
	dig_spot_instance.global_position = current_cell_pos
	dig_spot_instance.anchor_cell = current_cell
	var plant: Plant = dig_spot_instance._spawn_plant_no_seed(plant_name)
	plant.stage_complete.connect(_on_plant_stage_complete)

func _on_dropped(_pickable):
	if blossy.can_respawn:
		type_writer.display_text(dropped_message_respawn)
		return
		
	if current_message_pos <= 3:
		type_writer.display_text(dropped_message)
	
func _process(_delta: float) -> void:
	if blossy.can_respawn: 
		return
	
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
			order_display.visible = false
			shield.visible = true
			type_writer.display_text("Ach.. das war nur ein Baum.")
			something_behind_notifier.visible = false
			is_squish_blocked = false
			is_event_completed = true
			day_cycle_manager.tween_to_time(0.0,  2.0, 20.0)
			return true
			
	if event_name == "bobo_appears":
		if bobo_appears_notifier.is_on_screen():
			is_squish_blocked = true
			type_writer.display_text("Was ist das?")
			bobo_follower.move_bobo(0.5, 1.0)
			day_cycle_manager.tween_to_time(2.0,  4.0, 20.0)
			return true 
	
	if event_name == "spawn_plant":
		spawn_dig_spot_with_plant("TutorialBlubburuPlant")
		day_cycle_manager.tween_to_time(4.0, 6.0, 20.0)
		return true

	return false

func event_end(_event_name: String) -> void:
	is_squish_blocked = false
	current_event = "none"

func _on_plant_stage_complete(stage: int) -> void:
	match stage:
		0:
			type_writer.display_text("...")
		1: 
			# All stages done
			type_writer.display_text("Nimm die Früchte und füttere ihn.")
		2:
			# Fruit event complete
			is_event_completed = true

func _on_bobo_path_follow_3d_bobo_done_moving() -> void:
	if current_event == "bobo_appears":
		is_event_completed = true
		bobo.sit_down()

func _on_bobo_bobo_ate(amount: int) -> void:
	if amount == 3: 
		bobo.hit_shield()
		tool_area.visible = true
		$"../../Clock2".visible = true
		
		# Blossy respawns, Textboxes dissappear
		type_writer.should_hide_in_time = true
		blossy.enable_respawn()
		type_writer.display_text("Eine bestellung...? Suche Samen und Pflanze sie ein!")
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_P:
			spawn_dig_spot_with_plant("TutorialBlubburuPlant")
