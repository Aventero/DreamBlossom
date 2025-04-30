@tool
extends Node3D
class_name Bobo

signal bobo_sat_down

@export_range(0.0, 1.0) var blend_open: float = 0
@export var player_camera: Camera3D
@onready var head: MeshInstance3D = $Armature/Skeleton3D/Head
@onready var animation_tree: AnimationTree = $AnimationTree
@export var nose_bone: BoneAttachment3D

# Blending
@export_tool_button("hit_shield") var blinking = hit_shield
@export_tool_button("Yawn") var yawning = yawn
@export_tool_button("Attack") var attacking = attack
@export_tool_button("Munch") var munching = munch.bind(3)
@export_tool_button("OpenMouth") var open = open_mouth
@export_tool_button("CloseMouth") var close = close_mouth
@export var max_order_fails : int = 3

var _failed_orders : int = 0

# Animations
# Head 
@export var head_turn_influence: float = 0.5
@export var head_turn_speed: float = 2.0
@onready var skeleton: Skeleton3D = $Armature/Skeleton3D
@onready var head_bone: int = skeleton.find_bone("Head_2")
var current_head_pose: Transform3D
var target_head_pose: Transform3D

# Eye
@export var eye_look_weight: float = 10
@export var eye_turn_speed: float = 5.0

# Blinking, yawning, breathing
var blink_timer: float = 0.0
var next_blink_time: float = randf_range(2.0, 7.0)
var yawn_timer: float = 0.0
var next_yawn_time: float = randf_range(30.0, 60.0)
var breathe_timer: float = 0.0
var next_breath_time: float = 8.0
var emotion_timer: float = 0.0
var next_emotion_time: float = randf_range(5.0, 10.0)
var active_tweens = []
var active_emotion_tweens = []
var is_yawning: bool = false

# Game State
signal level_failed

# TWEENS
func create_tracked_tween(is_emotion: bool = false) -> Tween:
	var tween = create_tween()
	if is_emotion: active_emotion_tweens.append(tween)
	active_tweens.append(tween)
	tween.finished.connect(func(): active_tweens.erase(tween))
	return tween

func smile() -> void:
	var tween = create_tracked_tween(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Happy", 0.4, 1.0)
	tween.tween_interval(5.0)
	tween.tween_property(head, "blend_shapes/Happy", 0.0, 1.0)

func sadness() -> void:
	var tween = create_tracked_tween(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Sad", 0.4, 1.0)
	tween.tween_interval(5.0)
	tween.tween_property(head, "blend_shapes/Sad", 0.0, 1.0)
	
func angry() -> void:
	var tween = create_tracked_tween(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Anger", 0.2, 1.0)
	tween.tween_interval(1.0)
	tween.tween_property(head, "blend_shapes/Anger", 0.0, 1.0)
	
func suprised() -> void:
	var tween = create_tracked_tween(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Suprise", 0.4, 1.0)
	tween.tween_interval(3.0)
	tween.tween_property(head, "blend_shapes/Suprise", 0.0, 1.0)

func reset_emotions() -> void:
	var tween = create_tracked_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Happy", 0.0, 1.0)
	tween.tween_property(head, "blend_shapes/Anger", 0.0, 1.0)
	tween.tween_property(head, "blend_shapes/Sad", 0.0, 1.0)
	tween.tween_property(head, "blend_shapes/Suprise", 0.0, 1.0)

func blink() -> void:
	if is_yawning: return
	var tween = create_tracked_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(head, "blend_shapes/Blink", 1.0, 0.1)
	tween.tween_interval(0.04)
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Blink", 0.0, 0.2)

func yawn() -> void:
	is_yawning = true
	for active_tween in active_tweens:
		active_tween.kill()
	active_tweens.clear()
	
	var tween = create_tracked_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Close eyes partially during yawn
	tween.tween_property(head, "blend_shapes/Blink", 0.8, 0.5)
	
	# Start opening mouth in parallel with eyes
	tween.parallel().tween_property(head, "blend_shapes/Mouth", 0.5, 0.8)
	tween.parallel().tween_property(head, "blend_shapes/Nose", 1.0, 0.8)
	tween.parallel().tween_property(head, "blend_shapes/Sad", 1.0, 0.8)
	
	# Hold the yawn for a moment
	tween.tween_interval(1.4)
	tween.parallel().tween_property(head, "blend_shapes/Mouth", 0.7, 1.4)
	
	
	# Close mouth gradually
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Mouth", 0.05, 1.0)
	
	# Open eyes fully after mouth is mostly closed
	tween.parallel().tween_property(head, "blend_shapes/Blink", 0.0, 0.4)
	tween.parallel().tween_property(head, "blend_shapes/Nose", 0.0, 0.4)
	tween.parallel().tween_property(head, "blend_shapes/Sad", 0.0, 0.4)
	tween.set_trans(Tween.TRANS_SINE)
	tween.chain().tween_property(head, "blend_shapes/Mouth", 0.0, 0.4)
	tween.tween_callback(func(): is_yawning = false)
	reset_emotions()

func breathe() -> void:
	if is_yawning: return
	var tween = create_tracked_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Nose", 0.7, 2.0)
	tween.parallel().tween_property(head, "blend_shapes/Stretch", 0.1, 2.0)
	tween.parallel().tween_property(head, "blend_shapes/Squish", 0.1, 2.0)
	tween.tween_interval(1.0)
	tween.tween_property(head, "blend_shapes/Nose", 0.0, 2.0)
	tween.parallel().tween_property(head, "blend_shapes/Stretch", 0.0, 3.0)
	tween.parallel().tween_property(head, "blend_shapes/Squish", 0.0, 2.0)

func attack() -> void:
	var tween = create_tracked_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Initial show anger
	tween.tween_property(head, "blend_shapes/Blink", 0.3, 0.15)
	tween.parallel().tween_property(head, "blend_shapes/Anger", 1.0, 0.15)
	tween.parallel().tween_property(head, "blend_shapes/Nose", 0.5, 0.15)
	
	# Anticipation
	tween.tween_property(head, "blend_shapes/Stretch", 0.6, 0.1)
	
	# Mouth opens AFTER the anticipation
	tween.tween_property(head, "blend_shapes/Mouth", 1.0, 0.1)
	
	# ATTACK - with squish
	var attack_tween = tween.parallel()
	attack_tween.set_trans(Tween.TRANS_BACK)
	attack_tween.set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(head, "blend_shapes/Squish", 1.0, 0.08)
	
	# Hold open
	tween.tween_interval(0.1)
	
	# Close mouth quickly and hold
	tween.tween_property(head, "blend_shapes/Mouth", 0.0, 0.1)
	tween.tween_interval(0.05)
	
	# Return from squish with elastic bounce
	var bounce_tween = tween.chain()
	bounce_tween.set_trans(Tween.TRANS_BACK)
	bounce_tween.set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(head, "blend_shapes/Squish", 0.0, 0.25)
	
	# Reset expressions
	tween.tween_interval(0.2)
	tween.tween_property(head, "blend_shapes/Stretch", 0.0, 0.2)
	tween.parallel().tween_property(head, "blend_shapes/Anger", 0.0, 0.3)
	tween.parallel().tween_property(head, "blend_shapes/Nose", 0.0, 0.3)
	tween.parallel().tween_property(head, "blend_shapes/Blink", 0.0, 0.3)

func munch(repeat_count: int = 5) -> void:
	var tween = create_tracked_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Start with happy expression
	tween.tween_property(head, "blend_shapes/Happy", 1.0, 0.3)
	tween.tween_interval(0.15)
	
	# Repeat the munching cycle
	for i in range(repeat_count):
		# Open mouth
		var open_tween = tween.chain()
		open_tween.tween_property(head, "blend_shapes/Mouth", 0.1, 0.15)
		open_tween.tween_property(head, "blend_shapes/Stretch", 0.2, 0.15)
		tween.tween_interval(0.08)
		
		# Close mouth with squish (impact)
		var close_tween = tween.parallel()
		close_tween.tween_property(head, "blend_shapes/Mouth", 0.0, 0.1)
		tween.tween_property(head, "blend_shapes/Stretch", 0.0, 0.1)
		
		# Close Squish
		var squish_tween = tween.parallel()
		squish_tween.tween_property(head, "blend_shapes/Squish", 0.2, 0.05)
		
		# Hold the closed mouth squish position briefly
		tween.tween_interval(0.05)
		
		# Release squish gradually
		tween.tween_property(head, "blend_shapes/Squish", 0.0, 0.15)
		
		# Pause between munches
		tween.tween_interval(0.1)
	
	# Finish with satisfied expression
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Happy", 0.0, 0.2)  # Reduce happy expression
	tween.tween_property(head, "blend_shapes/Happy", 0.0, 0.2)  # Fade out happy expression

func open_mouth() -> void:
	var tween = create_tracked_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(head, "blend_shapes/Mouth", 0.6, 0.5)


func play_eating_animation(munches: int) -> void:
	# Play eating animation
	var tween = create_tween()
	tween.tween_callback(open_mouth)
	tween.tween_interval(1.0)
	tween.tween_callback(munch.bind(3))

func close_mouth() -> void:
	var tween = create_tracked_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Mouth", 0.0, 0.5)
	
	var attack_tween = tween.chain()
	attack_tween.set_ease(Tween.EASE_OUT)
	attack_tween.set_trans(Tween.TRANS_BACK)
	attack_tween.tween_property(head, "blend_shapes/Squish", 0.5, 0.1)
	
	var bounce_tween = tween.chain()
	bounce_tween.set_ease(Tween.EASE_OUT)
	bounce_tween.set_trans(Tween.TRANS_BACK)
	bounce_tween.tween_property(head, "blend_shapes/Squish", 0.0, 0.25)

func handle_random_emotion(delta: float) -> void:
	emotion_timer += delta
	if emotion_timer < next_emotion_time:
		return

	emotion_timer = 0.0
	next_emotion_time = randf_range(10.0, 20.0)
	
	var rand = randf_range(0.0, 1.0)
	var is_smile = rand < 0.4
	var is_sad = rand > 0.4 && rand < 0.6
	var is_angry = rand > 0.6 && rand < 0.8
	var is_suprise = rand > 0.8 && rand < 1.0
	if is_smile: 
		smile()
	if is_sad: 
		sadness()
	if is_angry: 
		angry()
	if is_suprise: 
		suprised()

func handle_random_blinking(delta: float) -> void:
	blink_timer += delta
	if blink_timer >= next_blink_time:
		blink()
		blink_timer = 0.0
		next_blink_time = randf_range(2.0, 7.0)

func handle_random_yawning(delta: float) -> void:
	yawn_timer += delta
	if yawn_timer >= next_yawn_time:
		yawn()
		yawn_timer = 0.0
		next_yawn_time = randf_range(30.0, 90.0)

func handle_breathing(delta: float) -> void:
	breathe_timer += delta
	if breathe_timer >= next_breath_time:
		breathe_timer = 0
		breathe()

# SYSTEM

func _ready() -> void:
	if skeleton:
		current_head_pose = skeleton.get_bone_global_pose(head_bone)

func _process(delta: float) -> void:
	# chance to blink
	handle_random_blinking(delta)
	handle_random_yawning(delta)
	handle_breathing(delta)
	handle_random_emotion(delta)
	
	if player_camera:
		head_movement(delta)
		look_at_player_camera(delta)


# ANIMATION
func head_movement(delta: float) -> void:
	# Get the current animated pose
	var animated_pose: Transform3D = skeleton.get_bone_global_pose(head_bone)
	
	# Target position in local space
	var local_target = skeleton.global_transform.affine_inverse() * player_camera.global_position
	
	# Create the target pose that looks at the player while preserving the up direction
	target_head_pose = animated_pose.looking_at(local_target, Vector3.UP)
	
	# Interpolate between current and target poses using delta
	current_head_pose = current_head_pose.interpolate_with(target_head_pose, delta * head_turn_speed)
	
	# Apply the override with partial weight
	skeleton.set_bone_global_pose_override(head_bone, current_head_pose, head_turn_influence, true)

func look_at_player_camera(delta: float) -> void:
	# Get direction to player_camera
	var direction = nose_bone.global_transform.origin.direction_to(player_camera.global_transform.origin)
	var distance = nose_bone.global_transform.origin.distance_to(player_camera.global_transform.origin)
	
	# Only look if player_camera is within range
	var max_look_distance = 10.0
	if distance > max_look_distance:
		# Reset look values when player_camera is too far
		head.set("blend_shapes/LookHorizontal", 0)
		head.set("blend_shapes/LookVertical", 0)
		return
	
	var local_direction = nose_bone.global_transform.basis.inverse() * direction
	
	# Calculate horizontal and vertical components
	# X is left/right, Y is up/down, Z is forward/back
	var horizontal = local_direction.x
	var vertical = local_direction.y
	
	# Gradually adjust the blend shape values for smooth look
	var current_look_h = head.get("blend_shapes/LookHorizontal")
	var current_look_v = head.get("blend_shapes/LookVertical")
	
	var strength = (1.0 - (distance / max_look_distance)) * eye_look_weight
	var target_look_h = clamp(horizontal * strength, -1.0, 1.0)
	var target_look_v = clamp(vertical * strength, -1.0, 1.0)
	
	# Use lerp for smooth movement
	head.set("blend_shapes/LookHorizontal", lerp(current_look_h, target_look_h, delta * eye_turn_speed))
	head.set("blend_shapes/LookVertical", lerp(current_look_v, target_look_v, delta * eye_turn_speed))

func sit_down() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(animation_tree, "parameters/StateMachine/walk_to_sit/blend_position", 1.0, 3.0).from(-1.0)
	tween.tween_callback(bobo_sat_down.emit.bind())

func hit_shield() -> void:
	var state_machine = animation_tree.get("parameters/StateMachine/playback")
	state_machine.travel("shield_bash")

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	# completed the shield bash
	if anim_name == "Shield":
		$"../../../OrderDisplay".start_order()

# Game mechanics
func setup() -> void:
	# Connect new_order event from current level
	GameBase.level.new_order.connect(_on_new_order)

func _on_ingredient_trigger_body_entered(ingredient: Ingredient):
	print("INGREDIENT", ingredient)
	# Check if order is existing and order is currently running
	if not GameBase.level.current_order or GameBase.level.current_order and not GameBase.level.current_order.is_running():
		print("Curreont order runnignb?", GameBase.level.current_order.is_running())
		return
	
	if not ingredient is Ingredient:
		print("Its not a ingredient")
		return
	
	# Check if ingredient is still required in order
	if not GameBase.level.current_order.is_required(ingredient.type) or GameBase.level.current_order.get_remaining_amount(ingredient.type) == 0:
		print("Ingredient is not required")
		return
	
	# Can be eaten -> Order progress
	GameBase.level.current_order.progress_order(ingredient.type)
	
	play_eating_animation(3)
	despawn_ingredient(ingredient)

func despawn_ingredient(ingredient: Ingredient) -> void:
	# Despawn ingredient
	ingredient.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	ingredient.freeze = true
	
	var indigrent_tween : Tween = create_tween()
	indigrent_tween.tween_property(ingredient, "scale", Vector3(0.001, 0.001, 0.001), 0.5)
	await indigrent_tween.finished
	
	if ingredient and not ingredient.is_queued_for_deletion():
		ingredient.queue_free()

func _on_new_order(order : Order) -> void:
	# Connect complete event
	order.completed.connect(_on_order_complete)

func _on_order_complete(success : bool) -> void:
	if success:
		return
	
	if not success:
		# TODO: Hunger has to go down or something as player did something wrong?
		pass
	
	# Update failed orders counter
	_failed_orders += 1
	
	# TODO: ONCE HUNGER IS 0 PLAYER GETS EATEN
	if _failed_orders >= max_order_fails:
		_bobo_death()

func _bobo_death() -> void:
	print("Bobo killed you. Oh my.")
	level_failed.emit()
