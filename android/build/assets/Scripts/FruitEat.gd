extends Area3D

@onready var audio_player : AudioStreamPlayer3D = $FruitEatAudio
@onready var player_data : Node = get_node("/root/World/Game/Player")

func _on_body_entered(fruit : Node3D):
	# Restore hunger
	player_data.restore_food(5.0)
	
	# Despawn fruit
	fruit.queue_free()
	
	# Play nom nom sound
	if audio_player.playing:
		audio_player.stop()
	audio_player.play()
