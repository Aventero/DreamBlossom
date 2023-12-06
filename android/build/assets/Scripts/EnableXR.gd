extends Node3D

var xr_interface: XRInterface

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")
		
		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		Engine.physics_ticks_per_second = 90
		
		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")


func _on_timer_timeout():
	get_node("Player/Left Hand/HungerUI/Viewport/HungerDisplay/Layout/HungerLabel").text = str(Engine.get_frames_per_second())
