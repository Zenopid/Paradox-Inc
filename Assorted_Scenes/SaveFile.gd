extends Control

@onready var play_time:Label = $"%PlayTime"
@onready var current_level:Label = $"%CurrentLevel"
@onready var anim_player:AnimationPlayer = $"%AnimationPlayer"
@onready var start_button:Button = $"%Start"
@onready var delete_button:Button = $"%Delete"

func _ready():
	var level_info:LevelInfo = ResourceLoader.load(GenericLevel.SAVE_FILE_PATH)
	current_level.text = level_info.get_level_name()
	 


func _on_start_pressed():
	GlobalScript.load_game()


func _on_delete_pressed():
	for data in DirAccess.get_files_at(GlobalScript.SAVE_FILE_FOLDER):
		print(data)


func _on_return_pressed():
	hide()
