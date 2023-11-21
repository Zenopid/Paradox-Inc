extends Label

func _physics_process(delta):
	text = "FPS: " + str(Engine.get_frames_per_second())
