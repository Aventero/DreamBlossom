@icon("res://Textures/EditorIcons/ItemBelt.png")
class_name ItemBelt
extends Node3D

@export var distance_between_items : float = 0.15
@export var drop_distance : float = 0.3

@onready var path : Path3D = $ItemBelt
@onready var item_belt_slot : PackedScene = preload("res://Prefabs/Tools/ItemBeltSlot.tscn")

var _left_controller_pickup : XRToolsFunctionPickup
var _right_controller_pickup : XRToolsFunctionPickup

var _path_length : float
var _should_update : bool = false

var _hold_items : Array[XRToolsPickable] = []
var _item_slot_instances : Dictionary = {}
var _target_offsets : Dictionary
var _skip_slots : Array

func _ready():
	_left_controller_pickup = XRToolsFunctionPickup.find_left($"/root/World/Player")
	_left_controller_pickup.has_picked_up.connect(_picked_up_item)
	
	_right_controller_pickup = XRToolsFunctionPickup.find_right($"/root/World/Player")
	_right_controller_pickup.has_picked_up.connect(_picked_up_item)
	
	_path_length = path.curve.get_baked_length()

func _process(delta):
	if _hold_items.size() == 0:
		return
	
	# Calculate angles
	for item in _hold_items:
		_handle_item(item)
	
	if _should_update:
		_update_belt()
		_should_update = false

func _picked_up_item(item : XRToolsPickable):
	if not _hold_items.has(item):
		_hold_items.append(item)
		
		item.dropped.connect(_dropped_item)

func _dropped_item(item : XRToolsPickable):
	if _hold_items.has(item):
		_hold_items.erase(item)

func _handle_item(item : XRToolsPickable):
	# Check distance to belt / curve
	var item_curve_offset : float = path.curve.get_closest_offset(path.to_local(item.global_position))
	var item_curve_position : Vector3 = path.to_global(path.curve.sample_baked(item_curve_offset))
	
	if item_curve_position.distance_to(item.global_position) > drop_distance:
		# Erase slot instance
		if _item_slot_instances.has(item):
			# Erase target
			if _target_offsets.has(_item_slot_instances[item]):
				_target_offsets.erase(_item_slot_instances[item])
			
			# Remove slot
			var item_slot : ItemBeltSlot = _item_slot_instances[item]
			item_slot.remove()
			
			_item_slot_instances.erase(item)
		
		# Disconnect event
		if item.dropped.is_connected(_on_item_drop):
			item.dropped.disconnect(_on_item_drop)
		
		_update_target_positions()
		_should_update = true
		return
	else:
		# Connect event if not already happened
		if not item.dropped.is_connected(_on_item_drop):
			item.dropped.connect(_on_item_drop)
	
	# Spawn item slot
	if not _item_slot_instances.has(item):
		var item_slot_instance : ItemBeltSlot = item_belt_slot.instantiate()
		item_slot_instance.name = item.name
		path.add_child(item_slot_instance)
		_item_slot_instances[item] = item_slot_instance
		
		_skip_slots.append(item_slot_instance)
		_should_update = true
	
	var new_index : int = 0
	
	for target_offset in _target_offsets.keys():
		if not is_instance_valid(target_offset):
			continue
		
		if target_offset == _item_slot_instances[item]:
			continue
		
		if item_curve_offset > _target_offsets[target_offset]:
			new_index += 1
	
	if new_index != _item_slot_instances[item].get_index():
		# Move slot to correct index
		path.move_child(_item_slot_instances[item], new_index)
		_should_update = true
	
	_update_target_positions()

func _on_item_drop(item : XRToolsPickable):
	if _item_slot_instances.has(item):
		_item_slot_instances[item].set_item(item)

func _update_target_positions():
	var item_amount : int = path.get_child_count()
	
	var index : int = 0
	var offset : float = 0.0
	
	if item_amount % 2 == 0:
		index = item_amount / 2 - 1
		offset = (_path_length / 2.0) - (distance_between_items * float(index)) - distance_between_items / 2
	else:
		index = item_amount / 2
		offset = (_path_length / 2.0) - (distance_between_items * float(index))
	
	for i in item_amount:
		var belt_item : ItemBeltSlot = path.get_child(i)
		var new_progress : float = offset + i * distance_between_items
		_target_offsets[belt_item] = new_progress

func _update_belt():
	var item_amount : int = path.get_child_count()
	
	for i in item_amount:
		var belt_item : ItemBeltSlot = path.get_child(i)
		
		if not _target_offsets.has(belt_item):
			continue
		
		if _skip_slots.has(belt_item):
			belt_item.progress = _target_offsets[belt_item]
			_skip_slots.erase(belt_item)
		else:
			var tween : Tween = create_tween()
			tween.tween_property(belt_item, "progress", _target_offsets[belt_item], 0.2)
