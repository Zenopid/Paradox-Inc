class_name GeneralManager extends Node

signal setting_changed(setting_name, new_setting)

class VisualSettings:
	var camera_flash: bool = true 
	var camera_shake: bool = true
	var resolution: Vector2i = Vector2i(1152, 648)
	var v_sync_enabled: bool = true
	var fullscreen: bool = false

class AudioSettings:
	var sfx_volume: int = 100
	var bgm_volume: int = 100
	var game_volume: int = 100

class ControlSettings:
	var temp: int = 0
#	var jump_button = ProjectSettings.get_setting()
#	var crouch_button = KEW_

var hitstop_frames_remaining: int = 0
var HITSTOP_TIMESCALE: float = 0.2
var in_hitstop: bool = false

var visual_settings: VisualSettings = VisualSettings.new()
var audio_settings: AudioSettings = AudioSettings.new()
var control_settings: ControlSettings = ControlSettings.new()

var setting_class_names: = [
	"visual_settings",
	"audio_settings",
	"control_settings"
]

func _ready():
	pass
	# Initialize visual and audio settings
#	visual_settings.camera_flash = false
#	visual_settings.camera_shake = true
#
#	audio_settings.sfx_volume = 100
#	audio_settings.bgm_volume = 100
#	audio_settings.disable_sfx = false
	
	

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
						DisplayServer.window_set_size(new_setting)
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
	print_debug("Applying hitstop...")
	hitstop_frames_remaining = duration
	Engine.time_scale = HITSTOP_TIMESCALE
	in_hitstop = true 
	
func remove_hitstop():
	print_debug("Removing hitstop...")
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

	
