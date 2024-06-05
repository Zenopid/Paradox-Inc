extends Control 

var updated_settings = {}
signal control_changed()
signal controls_overlap()
signal invalid_control()

@onready var apply_button = $"%Apply"
@onready var settings_tab: TabContainer = $TabContainer


#Audio
@onready var game_slider = $"%Game_Volume"
@onready var sfx_slider = $"%SFX_Volume"
@onready var music_slider = $"%BGM_Volume"
@onready var enable_ui_sfx = $"%ui_sfx_enabled"

#Visual
@onready var camera_flash:CheckButton = $"%camera_flash"
@onready var camera_shake:CheckButton = $"%camera_shake"
@onready var v_sync:CheckButton = $"%v_sync_enabled"
@onready var fullscreen:CheckButton = $"%fullscreen"
@onready var resolution: OptionButton = $"%ResolutionOptions"
@onready var target_fps: OptionButton = $"%FPSOptions"
@onready var show_fps: CheckButton = $"%show_fps"
#Controls
@onready var jump_control:Button = $"%jump"
@onready var crouch_control:Button = $"%crouch"
@onready var left_control:Button = $"%left"
@onready var right_control:Button = $"%right"
@onready var attack_control:Button = $"%attack"
@onready var dodge_control:Button = $"%dodge"
@onready var timeline_control:Button = $"%swap_timeline"
@onready var options_control: Button = $"%options"
@onready var boost_control: Button = $"%boost"
@onready var rebind_screen = $"%Control_Rebind_Screen"
@onready var rebind_text:Label = $"%Rebind_Text"
@onready var overlapping_text:Label = $"%Overlapping_Text_Notification"
@onready var rebind_timer:Timer = $"%Rebind_Timer"

var current_setting_tab: String 

var invalid_inputs = [
	KEY_AMPERSAND,
	KEY_APOSTROPHE,
	KEY_ASCIICIRCUM,
	KEY_ASCIITILDE,
	KEY_ASTERISK,
	KEY_CTRL
]

var last_input: InputEvent

var level:GenericLevel

@onready var settings_resource:SettingsInfo = GlobalScript.settings_info

func _ready():
	if ResourceLoader.exists(settings_resource.get_save_path()):
		settings_resource = load(settings_resource.get_save_path())
	set_process_input(false)
	level = get_tree().get_first_node_in_group("CurrentLevel")
	current_setting_tab = settings_tab.get_current_tab_control().name.to_lower() + "_settings"
	rebind_screen.hide()
	#
	connect("controls_overlap", Callable(self, "_on_overlapping_controls").bind("Controls overlap."))
	connect("invalid_control", Callable(self, "_on_overlapping_controls").bind("Invalid input."))
	
	for i in get_tree().get_nodes_in_group("Toggle Buttons"):
		i.connect("toggled", Callable(self, "_on_setting_toggled").bind(i))
	
	init_settings()
	GlobalScript.emit_signal("entering_settings")
	
func init_settings():
	init_audio_settings()
	init_control_settings()
	init_visual_settings()

func init_audio_settings():
	game_slider.value = settings_resource.get_setting("game_volume")
	music_slider.value = settings_resource.get_setting("bgm_volume")
	sfx_slider.value = settings_resource.get_setting("sfx_volume")
	
	enable_ui_sfx.button_pressed = settings_resource.get_setting("ui_sfx_enabled")
	

	for nodes in get_tree().get_nodes_in_group("Music Testers"):
		nodes.connect("pressed", Callable(self, "_on_test_music_pressed").bind(nodes))

func init_visual_settings():
	camera_flash.button_pressed = settings_resource.get_setting("camera_flash")
	camera_shake.button_pressed = settings_resource.get_setting("camera_shake")
	v_sync.button_pressed = settings_resource.get_setting("v_sync_enabled")
	fullscreen.button_pressed = settings_resource.get_setting("fullscreen")
	show_fps.button_pressed = settings_resource.get_setting("show_fps")
	
	for i in resolution.get_item_count():
		var text = resolution.get_item_text(i)
		var item_text = text.split_floats("x")
		var res = Vector2i(int(item_text[0]), int(item_text[1]))
		if res == settings_resource.get_setting("resolution"):
			resolution.select(i)
			return
#		print_debug(res)
	print_debug("Couldn't find the current resolution " + str(settings_resource.get_setting("resolution")) + " in the available options.")

func _on_setting_toggled(toggled:bool, button:Button):
	check_if_setting_changed(button.name.to_lower(), toggled)

func init_control_settings(): 
	for nodes in get_tree().get_nodes_in_group("Rebind Buttons"):
		nodes.connect("pressed", Callable(self, "start_rebind").bind(nodes.name,nodes))

	if GlobalScript.controller_type == "Keyboard":
		for i in settings_resource.get_control_buttons():
			var current_button:String = i
			for input in settings_resource.get_setting(current_button):
				if input is InputEventKey:
					get(current_button.left(current_button.find("_")) + "_control").text = OS.get_keycode_string(input.unicode).capitalize()
					continue 
					#just assume first key
				elif input is InputEventMouseButton:
					get(current_button.left(current_button.find("_")) + "_control").text = input.as_text()
	else:
		for i in settings_resource.get_control_buttons():
			var current_button:String = i
			for input in settings_resource.get_setting(current_button):
				if input is InputEventJoypadButton :
					get(current_button.left(current_button.find("_")) + "_control").text = input.as_text()
					continue
	if options_control.text == "":
		if GlobalScript.controller_type == "Keyboard":
			options_control.text = "Escape"
			#engine bug i think

func check_if_setting_changed(setting_name:String, setting_condition: Variant):
	#print(GlobalScript.get_setting(current_setting_tab, setting_name))
	if setting_condition != settings_resource.get_setting(setting_name):
		updated_settings[setting_name] = {
			"value": setting_condition,
			"type": current_setting_tab
			}
	else:
		updated_settings.erase(setting_name)
	apply_button.visible = !updated_settings.is_empty()

func _on_apply_pressed():
	for new_setting in updated_settings.keys():
		var setting = updated_settings[new_setting]
		
		settings_resource.set_setting(setting["value"], new_setting)
		GlobalScript.apply_setting(setting["value"], new_setting)
	updated_settings.clear()
	apply_button.hide()

func _on_resolution_options_resolution_changed(new_resolution: Vector2i):
	check_if_setting_changed("resolution", new_resolution)

func _on_test_music_pressed(button):
	var music_player: AudioStreamPlayer = button.get_parent().get_node("Test_Music")
	
	if music_player.playing:
		music_player.stop()
	else:
		music_player.play()

func _on_return_button_pressed():
	ResourceSaver.save(settings_resource, settings_resource.get_save_path())
	GlobalScript.exit_settings()
	

func set_music_volume(value, slider):
	slider.get_parent().get_node("Test_Sound").volume_db = value 

func _input(event):
	last_input = event 
	if last_input.is_action_type() and last_input.is_pressed():
		if GlobalScript.controller_type == "Keyboard":
			if last_input is InputEventKey and last_input.is_pressed():
				if Input.is_physical_key_pressed(KEY_ESCAPE):
					rebind_screen.hide()
					return
				else:
					for i in invalid_inputs:
						if last_input["keycode"] == i:
							emit_signal("invalid_control")
							return
		#		else:
		#			for i in invalid_inputs:
		#				print(last_input.as_text())
		emit_signal("control_changed")
		set_process_input(false)


func start_rebind(event_name, button:Button):
	rebind_screen.show()
	set_process_input(true)
	await control_changed
	change_control(event_name, button)

func change_control(event_name, button:Button):
	rebind_screen.hide()
#	for i in invalid_inputs:
#		if last_input == i:
#			return
	if InputMap.has_action(event_name):
		for i in InputMap.action_get_events(event_name):
			if i == last_input:
				return
			#need to check overlapping inputs
		print("Last input is " + str(last_input))
		for i in InputMap.get_actions():
			if i.contains("ui"):
				continue
			print(i)
				#skip ui inputs they don't matter
			for x in InputMap.action_get_events(i):
				if x.is_match(last_input, true):
					print(str(i) + " has the input of " + str(last_input.as_text()))
					emit_signal("controls_overlap")
					return
				#overlapping inputs
	InputMap.action_erase_events(event_name)
	InputMap.action_add_event(event_name, last_input)
	button.text = last_input.as_text()      
	button.grab_focus()
	set_process_input(false)
	GlobalScript.change_ui_controls()

func _on_tab_container_tab_changed(tab):
	current_setting_tab = settings_tab.get_current_tab_control().name.to_lower() + "_settings"

func on_audio_slider_drag_ended(value_changed:bool, slider:HSlider):
	GlobalScript.apply_setting(slider.value, slider.name.to_lower())

func _on_overlapping_controls(display_text:String):
	rebind_text.hide()
	overlapping_text.text = display_text
	overlapping_text.show()
	rebind_screen.show()
	rebind_timer.start()
	await rebind_timer.timeout
	rebind_screen.hide()
	overlapping_text.hide()
	rebind_text.show()

func _on_tab_container_focus_entered():
	settings_tab.set("focus_next", get_node(current_setting_tab) )

func _on_visibility_changed():
	if level:
		level.visible = !visible

func _on_fps_options_item_selected(index):
	check_if_setting_changed("fps", int(target_fps.get_item_text(index)))


func _on_joypad_enabled_toggled(toggled_on):
	if toggled_on:
		GlobalScript.controller_type = "Controller"
	else:
		GlobalScript.controller_type = "Keyboard"



func _on_game_volume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	settings_resource.set_setting("game_volume", value)



func _on_sfx_volume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear_to_db(value))
	settings_resource.set_setting("sfx_volume", value)

func _on_bgm_volume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	settings_resource.set_setting("bgm_volume",value)
