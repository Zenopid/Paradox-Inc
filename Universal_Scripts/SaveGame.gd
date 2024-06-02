class_name SaveManager extends Resource

const SAVE_FILE_PATH:String = "user://save_data.sav"
const SAVE_GAME_BASE_PATH := "user://save"
@export var version:= 1

var level_data: GenericLevel
var player_data: Player


func write_savegame() -> void:
	ResourceSaver.save(self, SAVE_FILE_PATH)

static func save_exists() -> bool:
	return ResourceLoader.exists(SAVE_FILE_PATH)
	
static func load_savegame() -> Resource:
	if not ResourceLoader.has_cached(SAVE_FILE_PATH):
		return ResourceLoader.load(SAVE_FILE_PATH, "",ResourceLoader.CACHE_MODE_REPLACE)
	push_error("Couldn't find resource in location " + SAVE_FILE_PATH)
	return null


static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_BASE_PATH + extension
