extends PathFollow3D

@export var bobo: Node3D

func _ready() -> void:
	move_bobo(0, 0.5)
	
func move_bobo(from: float, to: float) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "progress_ratio", 1.0, 10.0)
	
