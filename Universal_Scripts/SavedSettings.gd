class_name SettingsInfo extends Resource

@export var SAVE_FILE_PATH: String = "user://save_info/user_settings.tres"

@export_category("Visual Settings")
@export var camera_flash: bool = true 
@export var camera_shake: bool = true
@export var resolution: Vector2i = Vector2i(120, 70)
@export var v_sync_enabled: bool = true
@export var fullscreen: bool = false
@export var show_fps:bool = false
@export var fps:int = Engine.physics_ticks_per_second

@export_category("Audio Settings")
@export var sfx_volume: int = 1
@export var bgm_volume: int = 1
@export var game_volume: int = 1
@export var ui_sfx_enabled: bool = true

@export_category("Control Settings")
@export var jump_button = InputMap.action_get_events("jump")
@export var crouch_button = InputMap.action_get_events("crouch")
@export var left_button = InputMap.action_get_events("left")
@export var right_button = InputMap.action_get_events("right")
@export var attack_button = InputMap.action_get_events("attack")
@export var dodge_button = InputMap.action_get_events("dodge")
@export var timeline_button = InputMap.action_get_events("swap_timeline")
@export var options_button = InputMap.action_get_events("options")
@export var boost_button = InputMap.action_get_events("boost")
@export var vibration:bool = true 

var button_names:PackedStringArray = [
	"jump_button",
	"crouch_button",
	"left_button",
	"right_button",
	"attack_button",
	"dodge_button",
	"timeline_button",
	"options_button",
	"boost_button",
]

func save():
	ResourceSaver.save(self,  SAVE_FILE_PATH)

func get_save_path():
	return SAVE_FILE_PATH

func get_setting(setting_name:String) -> Variant:
	if setting_name in self:
		return get(setting_name)
	print_debug("Couldn't find setting name")
	return null;

func set_setting(setting:Variant, setting_name:String):
	if setting_name in self:
		if typeof(setting) == typeof(get(setting_name)):
			set(setting_name, setting)
			return true
	return false

func has_setting(setting_name:String) -> bool:
	return setting_name in self

func get_control_buttons() -> PackedStringArray:
	return button_names
	
