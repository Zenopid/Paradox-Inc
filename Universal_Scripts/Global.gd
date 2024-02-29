class_name GeneralManager extends Node

signal setting_changed(setting_name, new_setting)
signal game_over

class VisualSettings:
	var camera_flash: bool = true 
	var camera_shake: bool = true
	var resolution: Vector2i = Vector2i(1152, 648)
	var v_sync_enabled: bool = true
	var fullscreen: bool = false

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
	var vibration:bool = true 

var hitstop_frames_remaining: int = 0
var HITSTOP_TIMESCALE: float = 0.2
var in_hitstop: bool = false

@onready var visual_settings: VisualSettings = VisualSettings.new()
@onready var audio_settings: AudioSettings = AudioSettings.new()
@onready var control_settings: ControlSettings = ControlSettings.new()

var setting_class_names: = [
	"visual_settings",
	"audio_settings",
	"control_settings"
]

func _ready():
	for i in control_settings.jump_button:
		var button = i
		if button is InputEventKey:
			var keycode_string = OS.get_keycode_string(button.get_key_label())
#			print(OS.get_keycode_string(button.key_label))
#		else:
#			print(button.as_text())
#	print(OS.get_keycode_string(control_settings.jump_button[0]))

func set_setting(setting_class:String, setting_name: String, new_setting):
	if setting_name in get(setting_class):
		get(setting_class).set(setting_name, new_setting)
		#updates records
		emit_signal("setting_changed", setting_name, new_setting)
		match setting_class:
			#actually applies changes to the game
			"visual_settings":
				match setting_name:
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
	print_debug("Couldn't set setting " + str(setting_name) + " in class " + str(setting_class) )

func get_setting(setting_class:String, setting_name:String):
	if setting_name in get(setting_class):
		return get(setting_class).get(setting_name)
	print_debug("Couldn't get setting " + str(setting_name) + " in class " + str(setting_class) )

func apply_hitstop(duration):
#	print_debug("Applying hitstop...")
	hitstop_frames_remaining = duration
	Engine.time_scale = HITSTOP_TIMESCALE
	in_hitstop = true 
	
func remove_hitstop():
#	print_debug("Removing hitstop...")
	in_hitstop = false
	Engine.time_scale = 1
	hitstop_frames_remaining = 0

func _physics_process(delta):
	if in_hitstop:
		Engine.time_scale = HITSTOP_TIMESCALE
		print(hitstop_frames_remaining)
		hitstop_frames_remaining -= 1
		if hitstop_frames_remaining <= 0:
			remove_hitstop()

	
