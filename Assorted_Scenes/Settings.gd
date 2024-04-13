extends Control 

var updated_settings = {}
signal control_changed()
signal controls_overlap()
signal exiting_settings()
signal invalid_control()

@onready var apply_button = $"%Apply"
@onready var settings_tab: TabContainer = $TabContainer


#Audio
@onready var game_slider = $"%Game_Volume"
@onready var sfx_slider = $"%SFX_Volume"
@onready var music_slider = $"%Music_Volume"
@onready var enable_ui_sfx = $"%ui_sfx_enabled"

#Visual
@onready var camera_flash:CheckButton = $"%camera_flash"
@onready var camera_shake:CheckButton = $"%camera_shake"
@onready var v_sync:CheckButton = $"%v_sync_enabled"
@onready var fullscreen:CheckButton = $"%fullscreen"
@onready var resolution: OptionButton = $"%ResolutionOptions"
@onready var fps: OptionButton = $"%FPSOptions"

#Controls
@onready var jump_control:Button = $"%jump"
@onready var crouch_control:Button = $TabContainer/Control/CrouchButton/crouch
@onready var left_control:Button = $TabContainer/Control/LeftButton/left
@onready var right_control:Button = $TabContainer/Control/RightButton/right
@onready var attack_control:Button = $TabContainer/Control/AttackButton/attack
@onready var dodge_control:Button = $TabContainer/Control/DodgeButton/dodge
@onready var timeline_control:Button = $TabContainer/Control/TimelineButton/swap_timeline
@onready var options_control: Button = $TabContainer/Control/OptionsButton/options
@onready var boost_control: Button = $"%boost"
@onready var rebind_screen = $Control_Rebind_Screen
@onready var rebind_text:Label = $"%Rebind_Text"
@onready var overlapping_text:Label = $"%Overlapping_Text_Notification"
@onready var timer:Timer = rebind_screen.get_node("Timer")

var current_setting_tab: String 
var new_visual_settings = GlobalScript.VisualSettings.new()
var new_audio_settings = GlobalScript.AudioSettings.new()
var new_control_settings = GlobalScript.ControlSettings.new()


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

func _ready():
	set_process_input(false)
	level = get_tree().get_first_node_in_group("CurrentLevel")
	current_setting_tab = settings_tab.get_current_tab_control().name.to_lower() + "_settings"
	rebind_screen.hide()
	
	connect("controls_overlap", Callable(self, "_on_overlapping_controls").bind("Controls overlap."))
	connect("invalid_control", Callable(self, "_on_overlapping_controls").bind("Invalid input."))
	
	for i in get_tree().get_nodes_in_group("Toggle Buttons"):
		i.connect("toggled", Callable(self, "_on_setting_toggled").bind(i))
	
	init_audio_settings()
	init_visual_settings()
	init_control_settings()

func init_audio_settings():
	game_slider.value = db_to_linear(GlobalScript.audio_settings.game_volume)
	music_slider.value = db_to_linear(GlobalScript.audio_settings.bgm_volume)
	sfx_slider.value = db_to_linear(GlobalScript.audio_settings.sfx_volume)
	enable_ui_sfx.button_pressed = GlobalScript.audio_settings.ui_sfx_enabled
	
	for nodes in get_tree().get_nodes_in_group("Music Sliders"):
		nodes.connect("value_changed", Callable(self, "set_music_volume").bind(nodes))
		nodes.connect("drag_ended", Callable(self, "on_audio_slider_drag_ended").bind(nodes))
		
	for nodes in get_tree().get_nodes_in_group("Music Testers"):
		nodes.connect("pressed", Callable(self, "_on_test_music_pressed").bind(nodes))

func init_visual_settings():
	camera_flash.button_pressed = GlobalScript.visual_settings.camera_flash
	camera_shake.button_pressed = GlobalScript.visual_settings.camera_shake
	v_sync.button_pressed = GlobalScript.visual_settings.v_sync_enabled
	fullscreen.button_pressed = GlobalScript.visual_settings.fullscreen
	
	for i in resolution.get_item_count():
		var text = resolution.get_item_text(i)
		var item_text = text.split_floats("x")
		var res = Vector2i(int(item_text[0]), int(item_text[1]))
		if res == GlobalScript.visual_settings.resolution:
			resolution.select(i)
			return
#		print_debug(res)
	print_debug("Couldn't find the current resolution " + str(GlobalScript.visual_settings.resolution) + " in the available options.")

func _on_setting_toggled(toggled:bool, button:Button):
	check_if_setting_changed(button.name.to_lower(), toggled)

func init_control_settings(): 
	for nodes in get_tree().get_nodes_in_group("Rebind Buttons"):
		nodes.connect("pressed", Callable(self, "start_rebind").bind(nodes.name,nodes))
	var input_type = "Keyboard"
	if Input.get_connected_joypads() != []:
		#there's a controller connected, so assume controller settings
		input_type = "Controller"
		print("Detected controller " + Input.get_joy_name(0))
	if input_type == "Keyboard":
		for i in GlobalScript.control_settings.get_property_list():
			var current_button:String = i["name"]
			if !current_button.contains("button"):
				continue
			for input in GlobalScript.control_settings.get(current_button):
				if input is InputEventKey:
					get(current_button.left(current_button.find("_")) + "_control").text = OS.get_keycode_string(input.unicode).capitalize()
					continue 
					#just assume first key
				elif input is InputEventMouseButton:
					get(current_button.left(current_button.find("_")) + "_control").text = input.as_text()
	else:
		for i in GlobalScript.control_settings.get_property_list():
			var current_button:String = i["name"]
			if !current_button.contains("button"):
				continue
			for input in GlobalScript.control_settings.get(current_button):
				if input is InputEventJoypadButton :
					get(current_button.left(current_button.find("_")) + "_control").text = input.as_text()
					continue
	if options_control.text == "":
		if input_type == "Keyboard":
			options_control.text = "Escape"
			#engine bug i think

func check_if_setting_changed(setting_name, setting_condition):
	#print(GlobalScript.get_setting(current_setting_tab, setting_name))
	if setting_condition != GlobalScript.get_setting(current_setting_tab, setting_name):
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
		
		GlobalScript.set_setting(setting["type"], new_setting, setting["value"])
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
	emit_signal("exiting_settings")
	if level:
		level.show()
	hide()

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
	if Input.get_connected_joypads() == []:
		for i in InputMap.get_actions():
			for x in InputMap.action_get_events(i):
				if x.is_match(last_input, true):
					emit_signal("controls_overlap")
					return
				#overlapping inputs
	InputMap.action_erase_events(event_name)
	InputMap.action_add_event(event_name, last_input)
	button.text = last_input.as_text()      
	button.grab_focus()
	set_process_input(false)

func _on_tab_container_tab_changed(tab):
	current_setting_tab = settings_tab.get_current_tab_control().name.to_lower() + "_settings"
	
#Audio Sliders
#func _on_master_slider_drag_ended(value_changed):
#	if value_changed:
#		updated_settings["game_volume"] = game_slider.value
#
#func _on_sfx_slider_drag_ended(value_changed):
#	if value_changed:
#		updated_settings["sfx_volume"] = sfx_slider.value
#
#func _on_music_slider_drag_ended(value_changed):
#	if value_changed:
#		updated_settings["bgm_volume"] = music_slider.value

func on_audio_slider_drag_ended(value_changed:bool, slider:HSlider):
	if value_changed:
		updated_settings[slider.name.to_lower()] = slider.value

func _on_overlapping_controls(display_text:String):
	rebind_text.hide()
	overlapping_text.text = display_text
	overlapping_text.show()
	rebind_screen.show()
	rebind_screen.get_node("Timer").start()
	await timer.timeout
	rebind_screen.hide()
	overlapping_text.hide()
	rebind_text.show()

func _on_tab_container_focus_entered():
	settings_tab.set("focus_next", get_node(current_setting_tab) )

func _on_visibility_changed():
	if level:
		level.visible = !visible

func _on_fps_options_item_selected(index):
	check_if_setting_changed("fps", int(fps.get_item_text(index)))
