extends Panel

@onready var hunger_slider : HSlider = $Layout/MarginContainer/Hunger
@onready var player_data : Node = get_node("/root/World/Game/Player")

func _ready():
	hunger_slider.max_value = player_data.max_hunger

func _process(delta):
	# Get hunger data and adjust slider
	hunger_slider.value = player_data.hunger
