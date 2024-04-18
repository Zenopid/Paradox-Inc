extends Control

@onready var play_time_tracker = $"%PlayTime"
@onready var current_level_tracker = $"%CurrentLevel"
@onready var start_button = $"%Start"
@onready var delete_button = $"%Delete"

const TOTAL_SAVE_FILES: int = 6

@onready var loading_screen: Control

func _ready():
	current_level_tracker.text = SaveSystem.get_var("CurrentLevel")["name"]
