class_name GameManager extends Node

@export var debug_enabled: bool = false 
@export var overwrite_previous_video: bool = false

signal setting_changed(setting_name, new_setting)
signal entering_settings()
signal exiting_settings()
signal game_over
signal level_over()
signal save_game_state()
signal level_start()

signal enabling_menu()
signal disabling_menu()


const SAVE_FILE_PATH:String  = "user://save_info/game_data.scn"
const SAVE_FILE_FOLDER:String = "user://save_info"

const HITSTOP_TIMESCALE: float = 0.2
const BOX_PATH: String = "uid://b812mbppojnhg"
const DARKSTALKER_PATH:String = "uid://bsn3xf0byil13"
const PLAYER_PATH:String = "uid://68mxs8vrodes"
const SWITCH_PATH:String = "uid://c1qqqb8ugmyry"
const CHECKPOINT_PATH:String = "uid://c5s048qamwl8p"
const PARAGHOUL_PATH: String = "uid://fcuvx05j2v0y"
const SETTINGS_PATH:String = "uid://do42anfb1sgba"
const GHOSTPLAYER_PATH:String = "uid://420r82wgwh4m"
const ENDSCREEN_PATH:String = "uid://clrxebh7buvqx"

#
#
#class VisualSettings:
	#var camera_flash: bool = true 
	#var camera_shake: bool = true
	#var resolution: Vector2i = Vector2i(120, 70)
	#var v_sync_enabled: bool = true
	#var fullscreen: bool = false
	#var show_fps:bool = false
	#var fps:int = Engine.physics_ticks_per_second
#class AudioSettings:
	#var sfx_volume: int = 1
	#var bgm_volume: int = 1
	#var game_volume: int = 1
	#var ui_sfx_enabled: bool = true
#class ControlSettings:
	#var jump_button = InputMap.action_get_events("jump")
	#var crouch_button = InputMap.action_get_events("crouch")
	#var left_button = InputMap.action_get_events("left")
	#var right_button = InputMap.action_get_events("right")
	#var attack_button = InputMap.action_get_events("attack")
	#var dodge_button = InputMap.action_get_events("dodge")
	#var timeline_button = InputMap.action_get_events("swap_timeline")
	#var options_button = InputMap.action_get_events("options")
	#var boost_button = InputMap.action_get_events("boost")
	#var vibration:bool = true 

var hitstop_frames_remaining: int = 0
var in_hitstop: bool = false
var old_hitstop_timescale: float = 1

var levels_beaten: int = 0

var free_play_enabled: bool = false
var time_trial_enabled:bool = false

var current_level: GenericLevel = null :
	set (value):
		current_level = value
	get: 
		return current_level
var current_player: Player = null :
	set (value):
		current_player = value
	get:
		return current_player

var current_ghost:GhostEntity = null

var game_time_start
var game_time_end
var total_game_time

@onready var settings_info: SettingsInfo = SettingsInfo.new()
#
#@onready var visual_settings: VisualSettings = VisualSettings.new()
#@onready var audio_settings: AudioSettings = AudioSettings.new()
#@onready var control_settings: ControlSettings = ControlSettings.new()
@onready var hitstop_manager: HitstopManager = $"%HitstopManager"
@onready var transition_screen: ColorRect = $"%TransitionScreen"
@onready var end_screen: EndScreen = $"%LevelEnd"
@onready var time_trial_end_screen: TimeTrialEndScreen = $"%GhostLevelEnd"
@onready var game_node:Node = $"%Game"
@onready var bgm:AudioStreamPlayer = $"%BGM"

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
	GROUND_FUTURE = 9,
	GROUND_PAST = 10,
	WALL_FUTURE = 11,
	WALL_PAST = 12,
	BOUNDARY_FUTURE = 13,
	BOUNDARY_PAST = 14, 
	HOOK_FUTURE = 15,
	HOOK_PAST = 16,
	PROJECTILE_FUTURE = 17,
	PROJECTILE_PAST = 18,
	PLAYER_STRIKE_HURTBOX_FUTURE = 19,
	PLAYER_STRIKE_HURTBOX_PAST = 20,
	ENEMY_STRIKE_HURTBOX_FUTURE = 21,
	ENEMY_STRIKE_HURTBOX_PAST = 22,
	PLAYER_PROJ_HURTBOX_FUTURE = 23,
	PLAYER_PROJ_HURTBOX_PAST = 24,
	ENEMY_PROJ_HURTBOX_FUTURE = 25,
	ENEMY_PROJ_HURTBOX_PAST = 26,
	STRIKE_HITBOX_FUTRUE = 27,
	STRIKE_HITBOX_PAST = 28
}
const LEVEL_PATHS = {
	"Emergence" = "uid://2ixcpeisj8it",
	"Training" = "uid://bdka6oxl4bhmn"
}

const BGM_PATHS = {
	"Training" = "uid://bpo757a5s16mi",
	"Emergence" = "uid://7cf3e500ewld"
}

#im guessing 127 lines by demo
#edit: im guessing no demo LMAO (due friday (end of march break), writing this on thursday...
#edit 2: i deleted the variable, didn't need it lol, also released demo (people thought it was mid)
#edit 3: i added the variable back, ignore the other 2 nimrods
#edit 4: variable is dying again, ignore the other 3 goofballs
#edit 5: edit 4 guy's pretty smart, now save and load is working


var save_num: int = 0
var controller_type: String = "Keyboard"

var main_menu: MainMenu

var settings_screen : Control
var ghost_data:PlayerGhost = PlayerGhost.new()

func _init():
	var settings_file_path = SettingsInfo.new()
	settings_file_path = settings_file_path.get_save_path()
	DirAccess.make_dir_recursive_absolute(SAVE_FILE_FOLDER)
	DirAccess.make_dir_recursive_absolute(PlayerGhost.SAVE_FILE_FOLDER)
	if ResourceLoader.exists(ghost_data.SAVE_FILE_PATH):
		ghost_data = ResourceLoader.load(ghost_data.SAVE_FILE_PATH)
	if ResourceLoader.exists(settings_file_path):
		settings_info = ResourceLoader.load(settings_file_path, "", ResourceLoader.CACHE_MODE_REPLACE)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settings_info.get_setting("game_volume")))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear_to_db(settings_info.get_setting("sfx_volume")))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(settings_info.get_setting("bgm_volume")))

func _ready():
	disable_transition_screen()
	settings_info.resolution = get_window().size
	change_ui_controls()
	ghost_data.init_dictionary()

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
	if controller_type == "Keyboard":
		for i in InputMap.action_get_events(input_name):
			if i is InputEventKey:
				InputMap.action_erase_event(input_name, i)
		var current_control = settings_info.get(button_controls)
		if current_control != null:
			for i in settings_info.get(button_controls):
				if i is InputEventKey:
					if !InputMap.action_has_event(input_name, i):
						InputMap.action_add_event(input_name, i)
			current_control = InputMap.action_get_events(button_controls.left(button_controls.find("_")))
	else:
		for i in InputMap.action_get_events(input_name):
			if i is InputEventJoypadButton:
				print("Deleting input " + str(i))
				InputMap.action_erase_event(input_name, i)
		var current_control = settings_info.get(button_controls)
		if current_control != null:
			for i in settings_info.get(button_controls):
				if i is InputEventJoypadButton:
					if !InputMap.action_has_event(input_name, i):
						InputMap.action_add_event(input_name, i)
			current_control = InputMap.action_get_events(button_controls.left(button_controls.find("_")))
		else:
			print(button_controls + " is null." )
			
func get_setting(setting_name:String):
	return settings_info.get_setting(setting_name)
	
func apply_setting(new_setting:Variant, setting_name: String):
	if settings_info.has_setting(setting_name):
		settings_info.set_setting(new_setting,setting_name)
		var setting = settings_info.get_setting(setting_name)
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
				get_window().size = new_setting
			"fullscreen":
				if new_setting:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				else:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			"sfx_volume":
				var index = AudioServer.get_bus_index("Sfx")
				AudioServer.set_bus_volume_db(index, linear_to_db(new_setting))
			"bgm_volume":
				var index = AudioServer.get_bus_index("Music")
				AudioServer.set_bus_volume_db(index, linear_to_db(new_setting))
			"game_volume":
				var index = AudioServer.get_bus_index("Game")
				AudioServer.set_bus_volume_db(index, linear_to_db(new_setting))
			_:
				print_debug("Couldn't set setting '" + str(setting_name) + "'")
	emit_signal("setting_changed", setting_name, new_setting)
	return
	#updates records

func apply_hitstop(duration):
	Engine.time_scale = HITSTOP_TIMESCALE
	await get_tree().create_timer(duration).timeout
	Engine.time_scale = 1

func save_game():
	settings_info.save()
	await get_tree().create_timer(0.5).timeout
	current_level.save()
	await get_tree().create_timer(0.5).timeout
	var game_as_packed_scene = PackedScene.new()
	current_level.set_owner(game_node)
	current_player.set_owner(game_node)
	set_children_owner(current_level)
	set_children_owner(current_player)
	for i in get_tree().get_nodes_in_group("MoveableObjects"):
		i.set_owner(game_node)
		await get_tree().create_timer(0.5).timeout
	game_as_packed_scene.pack(game_node)
	var error = ResourceSaver.save(game_as_packed_scene,SAVE_FILE_PATH,)
	if error != OK:
		print("Error " + str(error))
	error = ResourceSaver.save(ghost_data, ghost_data.SAVE_FILE_PATH)
	if error != OK:
		print("Error " + str(error))

func set_children_owner(node_to_check:Node):
	for child in node_to_check.get_children():
		child.set_owner(node_to_check)
		if child.get_children() != []:
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(child):
				set_children_owner(child)

func has_save() -> bool:
	return ResourceLoader.exists(SAVE_FILE_PATH)

func load_game():
	if has_save():
		var game_resource = ResourceLoader.load(SAVE_FILE_PATH)
		game_node.free()
		game_node = game_resource.instantiate()
		game_node.name = "Game"
		game_node.unique_name_in_owner = true 
		for i in game_node.get_children():
			if i is Player:
				current_player = i
			else:
				current_level = i
		
		current_level.add_to_group("CurrentLevel")
		current_player.add_to_group("Players")
		add_child(game_node)
		main_menu.disable_menu()
		current_player.request_ready()
		current_level.request_ready()

func start_level(level:String):
	main_menu.bgm.stop()
#	print("Starting level " + level)
	if !LEVEL_PATHS.has(level):
		push_error("Couldn't find level " + level)
	var new_level = load(LEVEL_PATHS[level])
	current_level = new_level.instantiate()
	current_level.add_to_group("CurrentLevel")
	game_node.add_child(current_level)
	var spawn_point = current_level.get_start_point()
	var player_instance = add_player(spawn_point)
	current_level.set_player(player_instance)
	current_level.start_level()
	game_time_start = Time.get_ticks_msec()
	if free_play_enabled:
		player_instance.change_grapple_status(true)
		player_instance.player_info.enable_all_items()
	main_menu.hide()
	bgm.stream = load(BGM_PATHS[current_level.name])
	bgm.play()

func restart_level():
	var level_name = current_level.name
	main_menu.hide()
	enable_transition_screen()
	emit_signal("game_over")
	await get_tree().create_timer(2).timeout
	main_menu.disable_menu()
	start_level(level_name)
	disable_transition_screen()

func end_level():
	bgm.stop()
	current_level.emit_signal("level_over")
	current_level.disable()
	current_player.disable()
	if !time_trial_enabled:
		end_screen.show()
		end_screen.end_level()
		await end_screen.screen_closed
	else:
		time_trial_end_screen.show()
		time_trial_end_screen.end_level()
		await time_trial_end_screen.screen_closed
	emit_signal("game_over")
	enable_transition_screen()
	await get_tree().create_timer(3).timeout
	disable_transition_screen()
	main_menu.enable_menu()
	
func enter_settings():
	var new_settings = load(SETTINGS_PATH)
	settings_screen = new_settings.instantiate()
	if is_instance_valid(current_level):
		current_level.disable()
	if is_instance_valid(current_player):
		current_player.disable()
	game_node.add_child(settings_screen)
	emit_signal("entering_settings")
	get_tree().paused = true 
	
func exit_settings():
	if is_instance_valid(current_level) and is_instance_valid(current_player):
		current_level.enable()
		current_player.enable()
	else:
		main_menu.enable_menu()
	settings_screen.queue_free()
	get_tree().paused = false
	settings_info = ResourceLoader.load(settings_info.get_save_path(), "", ResourceLoader.CACHE_MODE_REPLACE)
	emit_signal("exiting_settings")
	
func add_player(pos) -> Player: 
	var player_instance = load(PLAYER_PATH).instantiate()
	player_instance.position = pos
	player_instance.set_spawn(pos)
	player_instance.set_level( current_level )
	player_instance.add_to_group("Players")
	game_node.add_child(player_instance) 
	current_player = player_instance
	return player_instance
	
func _on_game_starting():
	game_time_start = Time.get_ticks_msec()

func enable_free_play():
	free_play_enabled = true 

func disable_free_play():
	free_play_enabled = false 

func enable_time_trial():
	time_trial_enabled = true

func disable_time_trial():
	time_trial_enabled = false

func enable_transition_screen():
	transition_screen.show()
	transition_screen.get_node("TransitionAnim").play("Loading")

func disable_transition_screen():
	transition_screen.hide()
	transition_screen.get_node("TransitionAnim").stop()


func _on_level_start():
	pass

func add_ghost(level_name:String, ghost_name:String):
	print_debug("Added ghost to game")
	var new_ghost: GhostEntity = load(GHOSTPLAYER_PATH).instantiate()
	new_ghost.set_ghost_info(ghost_data.saved_ghosts[level_name][ghost_name])
	game_node.add_child(new_ghost)
	current_ghost = new_ghost


func get_current_ghost() -> GhostEntity:
	return current_ghost
 
func _on_level_over():
	pass
	#var end_screen = load(ENDSCREEN_PATH).instantiate()
	#add_child(end_screen)
	#end_screen.end_level()
	#await game_over
	#enable_transition_screen()
	#await get_tree().create_timer(5).timeout
	##gives the game 5 seconds to clear everything out. seems pretty reasonable.
	#disable_transition_screen()
	#main_menu.enable_menu()


func _on_bgm_finished():
	bgm.play()

func stop_music():
	bgm.stop()
