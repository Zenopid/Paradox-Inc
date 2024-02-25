extends Control 

var updated_settings = {}
@onready var apply_button = $Apply
var current_setting_tab: String 
@onready var settings_tab: TabContainer = $TabContainer
var visual_settings_autocomplete = GlobalScript.VisualSettings.new()
var audio_settings_autocomplete = GlobalScript.AudioSettings.new()
var control_settings_autocomplete = GlobalScript.ControlSettings.new()

func _ready():
	for nodes in get_tree().get_nodes_in_group("Music Testers"):
		nodes.connect("pressed", Callable(self, "_on_test_music_pressed").bind(nodes))
	for nodes in get_tree().get_nodes_in_group("Music Sliders"):
		nodes.connect("value_changed", Callable(self, "set_music_volume").bind(nodes))

func _process(delta):
	if !updated_settings.is_empty():
		apply_button.show()
		apply_button.disabled = false
	else:
		apply_button.hide()
		apply_button.disabled = true 
	current_setting_tab = settings_tab.get_current_tab_control().name.to_lower() + "_settings"

func check_if_setting_changed(setting_name, setting_condition):
	if setting_condition != GlobalScript.get_setting(current_setting_tab, setting_name):
		updated_settings[setting_name] = setting_condition
	else:
		updated_settings.erase(setting_name)

func _on_enable_camera_flashing_toggled(button_pressed):
	check_if_setting_changed("camera_flash", button_pressed)

func _on_enable_camera_shaking_toggled(button_pressed):
	check_if_setting_changed("camera_shake", button_pressed)

func _on_enable_vsync_toggled(button_pressed):
	check_if_setting_changed("v_sync_enabled", button_pressed)

func _on_apply_pressed():
#func set_setting(setting_class:String, setting_name, new_setting):
	for new_setting in updated_settings.keys():
		GlobalScript.set_setting(current_setting_tab, new_setting, updated_settings[new_setting])
	updated_settings.clear()

func _on_resolution_options_resolution_changed(new_resolution: Vector2i):
	check_if_setting_changed("resolution", new_resolution)

func _on_enable_fullscreen_toggled(button_pressed):
	check_if_setting_changed("fullscreen", button_pressed)

func _on_master_slider_value_changed(value):
	check_if_setting_changed("game_volume", value)

func _on_sfx_slider_value_changed(value):
	check_if_setting_changed("sfx_volume", value)

func _on_test_music_pressed(button):
	var music_player: AudioStreamPlayer = button.get_parent().get_node("Test_Music")
	
	if music_player.playing:
		music_player.stop()
	else:
		music_player.play()


func _on_return_button_pressed():
	queue_free()

func set_music_volume(value, slider):
	slider.get_parent().get_node("Test_Music").volume = value 
