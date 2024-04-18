class_name GameManager extends Node

@export var debug_enabled: bool = false 

var BOX_PATH: String = "uid://b812mbppojnhg"
var DARKSTALKER_PATH:String = "uid://bsn3xf0byil13"
var PLAYER_PATH:String = "uid://68mxs8vrodes"
var SWITCH_PATH:String = "uid://c1qqqb8ugmyry"
var CHECKPOINT_PATH:String = "uid://c5s048qamwl8p"
var PARAGHOUL_PATH: String = "uid://fcuvx05j2v0y"
signal setting_changed(setting_name, new_setting)
signal game_over
signal level_over()
signal save_game_state()
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
	var boost_button = InputMap.action_get_events("boost")
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

enum collision_values {
	PLAYER_FUTURE = 1,
	PLAYER_PAST = 2,
	OBJECT_FUTURE = 3,
	OBJECT_PAST = 4,
	ENTITY_FUTURE = 5,
	ENTITY_PAST = 6,
	HITBOX_FUTURE = 7,
	HITBOX_PAST = 8,
	GROUND_FUTURE = 9,
	GROUND_PAST = 10,
	WALL_FUTURE = 11,
	WALL_PAST = 12,
	BOUNDARY_FUTURE = 13,
	BOUNDARY_PAST = 14,
	HOOK_FUTURE = 15,
	HOOK_PAST = 16
}
const LEVEL_PATHS = {
	"Emergence" = "uid://2ixcpeisj8it",
	"Training" = "uid://bdka6oxl4bhmn"
}

#im guessing 127 lines by demo
#edit: im guessing no demo LMAO (due friday (end of march break), writing this on thursday...
#edit 2: i deleted the variable, didn't need it lol, also released demo (people thought it was mid)
#edit 3: i added the variable back, ignore the other 2 nimrods
#edit 4: variable is dying again, ignore the other 3 goofballs


var save_num: int = 0
var controller_type: String = "Keyboard"

var main_menu: MainMenu
func _ready():
#	SaveSystem.connect("loaded", Callable(self, "load_game"))
	if !Input.get_connected_joypads() == []:
		controller_type = "Controller"
	visual_settings.resolution = get_window().size
	change_ui_controls()
	SaveSystem.set_var("MoveableObject", {})
	print(SaveSystem.get_var("MoveableObject"))
	
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
		"up": button_controls = "jump"
		"down": button_controls = "crouch"
		"accept": button_controls = "attack"
		"focus_prev": button_controls = "view_timeline"
		"focus_next": button_controls = "next_timeline"
		_: button_controls = ui_input
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
					"resolution": get_window().size = new_setting
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

func save_game():
	for nodes in get_tree().get_nodes_in_group("Persist"):
		nodes.save()
	SaveSystem.save()

func has_save() -> bool:
	if SaveSystem.get_var("Player"):
		#surely the player is in every save right...
		return true 
	return false
	
func load_game():
	if has_save():
		start_level(SaveSystem.get_var("CurrentLevel")["name"])
		for nodes in get_tree().get_nodes_in_group("Persist"):
			nodes.load_from_file()
			if nodes.is_in_group("MoveableObject"):
				var moveable_objects = SaveSystem.get_var("MoveableObject")
				for objects in moveable_objects.keys():
					var current_object = moveable_objects[objects]
					if current_object["id"] == nodes.get_id() and current_object["id"] != 0:
						#if its 0, its the generic value and is not special so it can safely be ignored
						#if they're equal and 1 isn't 0, then the other also must not be 0
						nodes.queue_free()
					var box_path = load(BOX_PATH)
					var box_instance = box_path.instantiate()
					var saved_properties = moveable_objects[objects]
					saved_properties.erase("type")
					for properties in saved_properties:
						set(properties, saved_properties[properties])
		return true
	return false

func start_level(level:String):
	print("Starting level " + level)
	var new_level = load(LEVEL_PATHS[level])
	current_level = new_level.instantiate()
	current_level.add_to_group("CurrentLevel")
	add_child(current_level)
	var spawn_point = current_level.get_start_point()
	var player_instance = add_player(spawn_point)
	current_level.set_player(player_instance)
	current_level.start_level()
	game_time_start = Time.get_ticks_msec()
	
func add_player(pos) -> Player: 
	var player = load(PLAYER_PATH)
	var player_instance = player.instantiate()
	player_instance.position = pos
	player_instance.set_spawn(pos)
	player_instance.set_level( current_level )
	player_instance.add_to_group("Players")
	add_child(player_instance) 
	return player_instance
#	var level_name = SaveSystem.get_var("current_level")
#	var delete_objects = true
#	if SaveSystem.get_var("current_level"):
#		var level_name = SaveSystem.get_var("current_level")["name"]
#		print(level_name)
#		if current_level.name == level_name:
#			delete_objects  = false
#			print("not deleting objects, cuz the current level was " + level_name)
#	if delete_objects:
#		for nodes in get_tree().get_nodes_in_group("Persist"):
#			if nodes is MoveableObject:
#				nodes.destroy()
#				#need to destroy current objects and replace them with saved objects
#				#they have to be reinstaintied as they may not have existed in the orignal level scene
#			else:
#				nodes.load_from_file()
#		var object_data = SaveSystem.get_var("MoveableObjects")
#		if typeof(object_data) != TYPE_NIL:
#			for i in object_data.keys():
#		#			print(object_data[i]["type"] + " is the current type.")
#				match object_data[i]["type"]:
#					"Box":
#						var box_path = load(BOX_PATH)
#						var box_instance = box_path.instantiate()
#						for x in object_data[i].keys():
#							if x != "type":
#								box_instance.set(x, object_data[i][x])
#						current_level.add_child(box_instance)
#			#	var save_nodes = get_tree().get_nodes_in_
#	else:
#		for nodes in get_tree().get_nodes_in_group("Persist"):
#			nodes.load_from_file()
#	for node in save_nodes:
#		if node.scene_file_path.is_empty():
#			print_debug("node isn't instanced, skipped " % node.name)
#			continue
#		if !node.has_method("save"):
#			print_debug("node doesn't have save func, skipped " % node.name)
#
#		var node_data = node.call("save")
#		var json_string = JSON.stringify(node_data)
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

#func get_save_files():
#	return save_files
#
#func load_save_file(file_number):
#	var requested_file = save_files["File" + str(file_number)]
#	if requested_file != OK:
#		return
#	requested_file = save_files["File" + str(file_number)]["game_data"]
#	var player_data = requested_file["player_info"]
#	var level_data = requested_file["level_info"]
#	total_game_time = requested_file["playtimme"]
#	var level_path = "res://Levels/"
#	var level:PackedScene = load (level_path + level_data["level_name"] + ".tscn")
#	var level_instance: GenericLevel = level.instantiate()
#	level_instance = requested_file["level_conditions"]
#	var main = get_tree().get_first_node_in_group("Main")
#	main.add_child(level_instance)

