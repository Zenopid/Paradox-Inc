extends Label

func _ready():
	var show_fps:bool = GlobalScript.get_setting("show_fps")
	visible = show_fps
	GlobalScript.connect("setting_changed", Callable(self, "_on_setting_changed"))

func _on_setting_changed(setting_name, new_setting):
	if setting_name == "show_fps":
		visible = GlobalScript.get_setting("show_fps")
func _physics_process(delta):
	text = "FPS: " + str(Engine.get_frames_per_second())
