extends Node3D

@export_group("Node References")
@export var pickable: XRToolsPickable
@export var type_writer: TypeWriter
@export var pickup_sprite_animation: AnimatedSprite2D
@export var squish_sprite_animation: AnimatedSprite2D
@export var something_behind_notifier: VisibleOnScreenNotifier3D
@export var tool_table: Node3D

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

func _ready() -> void:
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
	
	if current_message_pos in event_name_at:
		do_special_event(event_name_at[current_message_pos])
	
	# double press shows full text
	if type_writer.is_displaying():
		type_writer.show_full_text()
	else:
		type_writer.display_text(squish_messages[current_message_pos])
		current_message_pos += 1
	
func _on_picked_up(_pickable):
	# Has to learn squishing (first pick up)
	if current_message_pos == 0:
		type_writer.display_text(pickup_message)
		squish_sprite_animation.visible = true
	
	# display text
	pickup_sprite_animation.visible = false
	
func _on_dropped(_pickable):
	pickup_sprite_animation.visible = true
	type_writer.display_text(dropped_message)
	
func do_special_event(event_name: String) -> void:
	if event_name == "look_behind":
		# Is already looking behind the dig spot
		# just make the plot appear, disable the notifier
		if something_behind_notifier.is_on_screen():
			tool_table.visible = true
			type_writer.display_text("Oh.. god.. look behind you.")
			something_behind_notifier.visible = true
			is_squish_blocked = false
		else: 
			# Player has to look behind
			current_event = event_name
			type_writer.display_text("Oh.. whats that behind you?")
			is_squish_blocked = true

func _on_something_behind_screen_entered() -> void:
	# Player looked on the thing now enable the table
	if current_event == "look_behind":
		current_event = "none"
		is_squish_blocked = false
		type_writer.display_text("Oh.. it was just the tree")
		tool_table.visible = true
		something_behind_notifier.visible = false
