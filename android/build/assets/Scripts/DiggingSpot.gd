extends Node3D

@onready var digging_spot : Node3D = $DirtHill
@onready var digging_spot_dug : Node3D = $DirtHillDug

func _on_collision_body_entered(body : Node3D):
	print("Object entered")
	
	# Check if entered object is held shovel
	if body.is_in_group("Shovel"):
		print("Shovel")
