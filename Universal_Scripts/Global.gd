class_name GameManager extends Node

@export var debug_enabled: bool = false 

signal setting_changed(setting_name, new_setting)
signal game_over
signal level_over()
signal update_settings()
signal starting_game()

signal enabling_menu()
signal disabling_menu()

class VisualSettings:
	var camera_flash: bool = true 
	var camera_shake: bool = true
	var resolution: Vector2i = Vector2i(120, 70)
	var v_sync_enabled: bool = true
	var fullscreen: bool = false
	var show_fps:bool = false
	var fps:int = Engine.physics_ticks_per_second
class AudioSettings:
	var sfx_volume: int = 1
	var bgm_volume: int = 1
	var game_volume: int = 1
	var ui_sfx_enabled: bool = true

class ControlSettings:
	var jump_button = InputMap.action_get_events("jump")
	var crouch_button = InputMap.action_get_events("crouch")
	var left_button = InputMap.action_get_events("left")
	var right_button = InputMap.action_get_events("right")
	var attack_button = InputMap.action_get_events("attack")
	var dodge_button = InputMap.action_get_events("dodge")
	var timeline_button = InputMap.action_get_events("swap_timeline")
	var options_button = InputMap.action_get_events("options")
	var boost_button = InputMap.action_get_events("grapple_boost")
	var vibration:bool = true 

var hitstop_frames_remaining: int = 0
var HITSTOP_TIMESCALE: float = 0.2
var in_hitstop: bool = false
var old_hitstop_timescale: float = 1

var levels_beaten: int = 0

var current_level: GenericLevel = null :
	set (value):
		current_level = value
	get: 
		return current_level
		
var save_files = {}
var game_time_start
var game_time_end
var total_game_time

@onready var visual_settings: VisualSettings = VisualSettings.new()
@onready var audio_settings: AudioSettings = AudioSettings.new()
@onready var control_settings: ControlSettings = ControlSettings.new()


var setting_class_names: = [
	"visual_settings",
	"audio_settings",
	"control_settings"
]

#im guessing 127 lines by demo
#edit: im guessing no demo LMAO (due friday (end of march break), writing this on thursday...
var game_data: Dictionary

var player_instance: Player

var completed_levels = {
	"Emergence": false
}

var controller_type: String = "Keyboard"
func _ready():
	if !Input.get_connected_joypads() == []:
		controller_type = "Controller"
	visual_settings.resolution = get_window().size
	change_ui_controls()
	
func change_ui_controls():
	set_ui_input("ui_up")
	set_ui_input("ui_down")
	set_ui_input("ui_left")
	set_ui_input("ui_right")
	set_ui_input("ui_accept")
	set_ui_input("ui_focus_prev")
	set_ui_input("ui_focus_next")

func set_ui_input(input_name: String):
	if !InputMap.has_action(input_name):
		print_debug("Couldn't find action name " + input_name)
		return
	var ui_input = input_name.right(-input_name.find("_") - 1)
	var button_controls: String 
	match ui_input:
		"up":
			button_controls = "jump"
		"down":
			button_controls = "crouch"
		"accept":
			button_controls = "attack"
		"focus_prev":
			button_controls = "view_timeline"
		"focus_next":
			button_controls = "next_timeline"
		_:
			button_controls = ui_input
	button_controls += "_button"
	if Input.get_connected_joypads() == []:
		for i in InputMap.action_get_events(input_name):
			if i is InputEventKey:
				InputMap.action_erase_event(input_name, i)
		var current_control = control_settings.get(button_controls)
		if current_control != null:
			for i in control_settings.get(button_controls):
				if i is InputEventKey:
					if !InputMap.action_has_event(input_name, i):
						InputMap.action_add_event(input_name, i)
			current_control = InputMap.action_get_events(button_controls.left(button_controls.find("_")))
	else:
		for i in InputMap.action_get_events(input_name):
			if i is InputEventJoypadButton:
				InputMap.action_erase_event(input_name, i)
		if control_settings.get(button_controls + "_button") != null:
			for i in control_settings.get(button_controls + "_button"):
				if i is InputEventJoypadButton:
					if !InputMap.action_has_event(input_name, i):
						InputMap.action_add_event(input_name, i)
func set_setting(setting_class:String, setting_name: String, new_setting):
	if setting_name in get(setting_class):
		get(setting_class).set(setting_name, new_setting)
		#updates records
		emit_signal("setting_changed", setting_name, new_setting)
		match setting_class:
			#actually applies changes to the game
			"visual_settings":
				match setting_name:
					"fps":
						Engine.max_fps = new_setting
						Engine.physics_ticks_per_second = new_setting
						Engine.max_physics_steps_per_frame = new_setting
					"v_sync_enabled": 
						if new_setting:
							DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
						else:
							DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
					"resolution":
#						DisplayServer.window_set_size(new_setting)
						get_window().size = new_setting
					"fullscreen":
						if new_setting:
							DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
						else:
							DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			"audio_settings":
				match setting_name:
					"sfx_volume":
						var index = AudioServer.get_bus_index("Sfx")
						AudioServer.set_bus_volume_db(index, linear_to_db(new_setting))
					"bgm_volume":
						var index = AudioServer.get_bus_index("Music")
						AudioServer.set_bus_volume_db(index, linear_to_db(new_setting))
					"game_volume":
						var index = AudioServer.get_bus_index("Game")
						AudioServer.set_bus_volume_db(index, linear_to_db(new_setting))
			"control_settings": 
				pass
			_:
				print_debug("Could not find class name " + setting_class)
		return
	print_debug("Couldn't set setting '" + str(setting_name) + "' in class '" + str(setting_class) + "'" )

func get_setting(setting_class:String, setting_name:String):
	var setting = (get(setting_class)).get(setting_name)
	if typeof(setting) != TYPE_NIL:
		return setting
	print_debug("Couldn't get setting '" + str(setting_name) + "' in class '" + str(setting_class) + "'" )

func apply_hitstop(duration):
#	print_debug("Applying hitstop...")
	hitstop_frames_remaining = duration
	old_hitstop_timescale = Engine.time_scale
	Engine.time_scale = HITSTOP_TIMESCALE
	in_hitstop = true 
	
func remove_hitstop():
#	print_debug("Removing hitstop...")
	in_hitstop = false
	Engine.time_scale = old_hitstop_timescale
	hitstop_frames_remaining = 0

func _physics_process(delta):
	if in_hitstop:
		Engine.time_scale = HITSTOP_TIMESCALE
		#print(hitstop_frames_remaining)
		hitstop_frames_remaining -= 1
		if hitstop_frames_remaining <= 0:
			remove_hitstop()

func save_game(player_status:Player, current_save_file: int = 1):
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		if node.scene_file_path.is_empty():
			print_debug("node isn't instanced, skipped " % node.name)
			continue
		if !node.has_method("save"):
			print_debug("node doesn't have save func, skipped " % node.name)
		
		var node_data = node.call("save")
		var json_string = JSON.stringify(node_data)
#	var player_spawn = player_status.get_spawn()
#	var starting_position:Vector2 = Vector2(player_spawn.global_position.x, player_spawn.global_position.y)
#	game_time_end = Time.get_ticks_msec()
#	total_game_time += abs(game_time_end - game_time_start)
#	var enemy_data = {}
#	var enemy_cnt = 1
#	for i in get_tree().get_nodes_in_group("Enemy"):
#		var current_enemy: Enemy = i
#		enemy_data[i.name + " " + str(enemy_cnt)] = {
#			"position": {
#				"x": current_enemy.global_position.x,
#				"y": current_enemy.global_position.y 
#				},
#			"type": current_enemy.name,
#			"health": current_enemy.health
#		}
#	var player_data = {
#	"player_position" = {
#		"x": starting_position.x,
#		"y": starting_position.y
#	},
#	"player_health" = player_status.health,
#	"items" = player_status.items
#	}
#	var level_data = {
#		"level_conditions" = player_status.get_level().level_conditions,
#		"level_name" = player_status.get_level().name
#	}
#	game_data = {
#		"player_info": player_data,
#		"enemy_info": enemy_data,
#		"level_info": level_data,
#		"playtime": total_game_time
#	}
#	save_files["File" + str(current_save_file)] = game_data

func _on_game_starting():
	game_time_start = Time.get_ticks_msec()

func get_save_files():
	return save_files

func load_save_file(file_number):
	var requested_file = save_files["File" + str(file_number)]
	if requested_file != OK:
		return
	requested_file = save_files["File" + str(file_number)]["game_data"]
	var player_data = requested_file["player_info"]
	var level_data = requested_file["level_info"]
	total_game_time = requested_file["playtimme"]
	var level_path = "res://Levels/"
	var level:PackedScene = load (level_path + level_data["level_name"] + ".tscn")
	var level_instance: GenericLevel = level.instantiate()
	level_instance = requested_file["level_conditions"]
	var main = get_tree().get_first_node_in_group("Main")
	main.add_child(level_instance)
