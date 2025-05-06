@tool
extends Node3D
class_name Bobo

signal bobo_sat_down
signal bobo_ate(amount: int)

@export var shield: Shield
@export_range(0.0, 1.0) var blend_open: float = 0
@export var player_camera: Camera3D
@onready var head: MeshInstance3D = $Armature/Skeleton3D/Head
@onready var animation_tree: AnimationTree = $AnimationTree
@export var nose_bone: BoneAttachment3D
@export var day_cycle_manager: DayCycleManager

# Blending
@export_tool_button("hit_shield") var blinking = hit_shield
@export_tool_button("Yawn") var yawning = yawn
@export_tool_button("Attack") var attacking = attack
@export_tool_button("Munch") var munching = munch.bind(3)
@export_tool_button("OpenMouth") var open = open_mouth
@export_tool_button("CloseMouth") var close = close_mouth
@export var max_order_fails : int = 3
@export var heart: Heart
@export var is_tutorial: bool = false

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
var is_waiting_for_food: bool = false
var is_eating: bool = false
var open_mouth_tween: Tween
var ingredients_eaten: int = 0

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
	
	if is_waiting_for_food or is_eating: return
	is_yawning = true
	for active_tween in active_tweens:
		active_tween.kill()
	active_tweens.clear()
	
	var tween = create_tracked_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	$BoboMhhLong.play()
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

func munch(repeat_count: int = 3) -> void:
	is_eating = true
	for active_tween in active_tweens:
		active_tween.kill()
	active_tweens.clear()
	
	var munch_tween = create_tracked_tween()
	munch_tween.set_ease(Tween.EASE_IN_OUT)
	munch_tween.set_trans(Tween.TRANS_SINE)
	
	# Start with happy expression
	munch_tween.tween_property(head, "blend_shapes/Happy", 1.0, 0.1)
	# Repeat the munching cycle
	for i in range(repeat_count):
		# Set smooth transitions
		munch_tween.set_trans(Tween.TRANS_SINE)  # Use sine for organic movement
		munch_tween.set_ease(Tween.EASE_IN_OUT)  # Smooth easing
		
		# Open mouth (group related animations properly)
		var open_sequence = munch_tween.parallel()
		open_sequence.tween_property(head, "blend_shapes/Mouth", 0.1, 0.1)
		open_sequence.tween_property(head, "blend_shapes/Stretch", 0.2, 0.1)
		
		# Small pause at maximum open
		munch_tween.tween_interval(0.01)
		
		# Close mouth (properly chained after opening completes)
		var close_sequence = munch_tween.parallel()
		close_sequence.tween_property(head, "blend_shapes/Mouth", 0.0, 0.07)
		close_sequence.tween_property(head, "blend_shapes/Stretch", 0.0, 0.07)
		
		# Add squish after closing completes (proper chaining)
		munch_tween.chain().tween_property(head, "blend_shapes/Squish", 0.2, 0.05)
		
		# Hold squish with a proper interval
		munch_tween.tween_interval(0.05)
		
		# Release squish with proper easing for organic movement
		munch_tween.set_ease(Tween.EASE_OUT)
		munch_tween.tween_property(head, "blend_shapes/Squish", 0.0, 0.07)
		
		# Ensure all animations complete before next cycle
		munch_tween.tween_interval(0.05)
	
	# Finish with satisfied expression
	munch_tween.set_ease(Tween.EASE_OUT)
	munch_tween.set_trans(Tween.TRANS_BACK)
	munch_tween.tween_property(head, "blend_shapes/Happy", 0.0, 0.2)  # Reduce happy expression
	munch_tween.tween_property(head, "blend_shapes/Happy", 0.0, 0.2)  # Fade out happy expression
	munch_tween.tween_callback(func(): is_eating = false)
	
func open_mouth() -> Tween:
	# Bobo is still having his mouth open 
	
	var tween = create_tracked_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(head, "blend_shapes/Mouth", 0.6, 0.5)
	return tween

func play_eating_animation(_munches: int) -> void:
	# Play eating animation
	var tween = create_tween()
	tween.tween_callback(munch.bind(3))

func close_mouth() -> Tween:
	open_mouth().kill()
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
	return tween

func handle_random_emotion(delta: float) -> void:
	if is_eating:
		return
		
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
	# Make bobo walk in the beginning
	if skeleton:
		current_head_pose = skeleton.get_bone_global_pose(head_bone)

func set_walk_blending(blend: float) -> void:
	animation_tree.set("parameters/StateMachine/walk_to_sit/blend_position", blend)

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
	# Make sure animation_tree is active
	animation_tree.active = true
	
	# Set the initial blend position if it's not already set
	animation_tree["parameters/StateMachine/walk_to_sit/blend_position"] = -1.0
	
	# Configure the tween
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Use a longer duration for smoother blending
	tween.tween_method(func(val: float): animation_tree["parameters/StateMachine/walk_to_sit/blend_position"] = val, -1.0, 1.0, 3.0)
	
	# Emit the signal when done
	tween.tween_callback(func(): bobo_sat_down.emit())

func hit_shield() -> void:
	var state_machine = animation_tree.get("parameters/StateMachine/playback")
	state_machine.travel("shield_bash")
	$ShieldHitTimer.start()

func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	print(GameBase.level.current_order)

# Game mechanics
func setup() -> void:
	# Connect new_order event from current level
	GameBase.level.new_order.connect(_on_new_order)
	GameBase.level.started_first_order.connect(_on_first_order_started)
	print("GameBase.level:", GameBase.level)
	print("GameBase.level.ordewr:", GameBase.level.current_order)

func _on_ingredient_open_mouth_entered(ingredient: Node3D):
	if not ingredient is Ingredient:
		print("Not a ingredient: ", ingredient.name)
	is_waiting_for_food = true
	open_mouth()

func _on_open_mouth_trigger_body_exited(_body: Node3D) -> void:
	close_mouth().tween_callback(func(): is_waiting_for_food = false)

func check_order_requirements(ingredient: Ingredient) -> bool:
	if not GameBase.level: 
		print("There is no level")
		return false
	
	if not GameBase.level.current_order: 
		print("There is no order")
		return false
	
	# Check if order is existing and order is currently running
	if not GameBase.level.current_order.is_running():
		print("Order not running")
		return false
	
	# Check if ingredient is still required in order
	if not GameBase.level.current_order.is_required(ingredient.type) or GameBase.level.current_order.get_remaining_amount(ingredient.type) == 0:
		print("Ingredient is not required")
		return false
		
	return true

func _on_ingredient_trigger_body_entered(ingredient: Node3D):
	if not ingredient is Ingredient:
		print("Not a ingredient: ", ingredient.name)
		return
	# Can be eaten -> Order progress
	if check_order_requirements(ingredient):
		GameBase.level.current_order.progress_order(ingredient.type)
		heart.feed_heart(ingredient.feed_amount, true)
	else:
		heart.feed_heart(ingredient.feed_amount / 2, false)
	
	play_eating_animation(3)
	despawn_ingredient(ingredient)
	ingredients_eaten += 1
	bobo_ate.emit(ingredients_eaten)
	$BoboNom.play()
	
func despawn_ingredient(ingredient: Ingredient) -> void:
	# Despawn ingredient
	ingredient.drop()
	ingredient.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	ingredient.freeze = true
	
	var indigrent_tween : Tween = create_tween()
	indigrent_tween.tween_property(ingredient, "scale", Vector3(0.001, 0.001, 0.001), 0.5)
	await indigrent_tween.finished
	
	if ingredient and not ingredient.is_queued_for_deletion():
		ingredient.queue_free()

# Connect complete event
func _on_new_order(order : Order) -> void:
	order.completed.connect(_on_order_complete)

func _on_order_display_order_completed() -> void:
	hit_shield()

# Some order is complete
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

# Player has to die
func _bobo_death() -> void:
	if is_tutorial: return
	level_failed.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_F:
			hit_shield()

# Bobo hits the shield
func _on_shield_hit_timer_timeout() -> void:
	# starts first or next order.
	shield.shield_hit()
	$ShieldHitApexTimer.start()
	
# Shield apex -> the order starts
func _on_shield_hit_apex_timer_timeout() -> void:
	$"../../../Shield/Chain_0/Chain_1/Chain_2/Chain_3/Shield/OrderDisplay".visible = true
	$"../../../Shield/Chain_0/Chain_1/Chain_2/Chain_3/Shield/OrderDisplay".start_order()
	print("Started order: ", GameBase.level.current_order)

# First order has started
func _on_first_order_started() -> void:
	heart.start_hunger()
	day_cycle_manager.set_day_start_time(6.00)
	day_cycle_manager.start_day()

# Player dies
func _on_heart_hunger_zero() -> void:
	_bobo_death()
