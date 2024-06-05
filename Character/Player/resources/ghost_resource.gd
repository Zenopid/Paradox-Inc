class_name PlayerGhost extends Resource

const SAVE_FILE_FOLDER: String = "user://ghost_data"

const SAVE_FILE_PATH:String = "user://save_info/ghost_data/ghosts.tres"

@export var saved_ghosts: = {
	"Training": {},
	"Emergence": {},
}

func init_dictionary():
	pass

func add_ghost_data(ghost_name:String = "User"):
	saved_ghosts[GlobalScript.current_level.name.capitalize()][ghost_name] = {
		"Locations": GlobalScript.current_player.player_positions,
		"Animations": GlobalScript.current_player.player_animations,
		"Checkpoint_Timestamps": GlobalScript.current_player.checkpoint_timestamps,
		"Date": Time.get_time_string_from_system()
		}
	save_ghost_data()

func get_ghost_data(player_name) -> Dictionary:
	if saved_ghosts[GlobalScript.current_level.name.capitalize()].has(player_name):
		return saved_ghosts[GlobalScript.current_level.name.capitalize()][player_name]
	GlobalScript.disable_time_trial()
	return {}

func save_ghost_data():
	ResourceSaver.save(self, SAVE_FILE_PATH )
