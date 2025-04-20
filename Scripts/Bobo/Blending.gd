@tool
extends Node3D

@export_range(0.0, 1.0) var blend_open: float = 0
@onready var head: MeshInstance3D = $Armature/Skeleton3D/Head
@export_tool_button("Blink") var blinking = blink
@export_tool_button("Yawn") var yawning = yawn
@export_tool_button("Attack") var attacking = attack
@export_tool_button("Munch") var munching = munch.bind(3)
@export_tool_button("OpenMouth") var open = open_mouth
@export_tool_button("CloseMouth") var close = close_mouth

func blink() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(head, "blend_shapes/Blink", 1.0, 0.1)
	tween.tween_interval(0.04)
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(head, "blend_shapes/Blink", 0.0, 0.2)

func yawn() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Close eyes partially during yawn
	tween.tween_property(head, "blend_shapes/Blink", 0.8, 0.5)
	
	# Start opening mouth in parallel with eyes
	tween.parallel().tween_property(head, "blend_shapes/Mouth", 0.5, 0.8)
	tween.parallel().tween_property(head, "blend_shapes/Nose", 1.0, 0.8)
	tween.parallel().tween_property(head, "blend_shapes/Sad", 1.0, 0.8)
	
	# Hold the yawn for a moment
	tween.tween_interval(0.4)
	
	# Close mouth gradually
	tween.tween_property(head, "blend_shapes/Mouth", 0.0, 0.7)
	
	# Open eyes fully after mouth is mostly closed
	tween.parallel().tween_property(head, "blend_shapes/Blink", 0.0, 0.4)
	tween.parallel().tween_property(head, "blend_shapes/Nose", 0.0, 0.4)
	tween.parallel().tween_property(head, "blend_shapes/Sad", 0.0, 0.4)
	
func attack() -> void:
	var tween = create_tween()
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
	var tween = create_tween()
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
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(head, "blend_shapes/Mouth", 0.6, 0.5)

func close_mouth() -> void:
	var tween = create_tween()
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

func _process(_delta: float) -> void:
	pass
