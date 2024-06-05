extends Control

@onready var play_time:Label = $"%PlayTime"
@onready var current_level:Label = $"%CurrentLevel"
@onready var anim_player:AnimationPlayer = $"%AnimationPlayer"
@onready var start_button:Button = $"%Start"
@onready var delete_button:Button = $"%Delete"
@onready var delete_timer:Timer = $"%DeleteTimer"

@onready var default_delete_color:Color
func _ready():
	var level_info:LevelInfo = ResourceLoader.load(GenericLevel.SAVE_FILE_PATH)
	current_level.text = level_info.get_level_name()
	play_time.text = msecs_to_text(level_info.player_time)
	anim_player.play("Enter")
	default_delete_color = delete_button.get("theme_override_colors/icon_pressed_color")



func _on_start_pressed():
	GlobalScript.load_game()


func _on_delete_pressed():
	anim_player.play("DeletingSave")
	delete_timer.start()
	
func _on_delete_button_up():
	delete_timer.stop()
	delete_button.set("theme_override_colors/font_pressed_color", default_delete_color)


func _on_return_pressed():
	hide()

func msecs_to_text(total_time) -> String:
	var minutes_played = roundi(total_time / 1000 /60)
	var seconds_played = roundi(total_time / 1000 % 60)
	var msecs_played = roundi(total_time%1000/10)

	if msecs_played < 10:
			if msecs_played == 0:
				msecs_played = "00"
			else:
				msecs_played = "0" + str(msecs_played)
	if minutes_played < 10:
		minutes_played = "0" + str(minutes_played)
	if seconds_played < 10:
		seconds_played = "0" + str(seconds_played)

	return str(minutes_played) + ":" + str(seconds_played) + ":" + str(msecs_played)



func _on_timer_timeout():
	DirAccess.remove_absolute(GlobalScript.SAVE_FILE_PATH)
	current_level.text = "Start New Game"
	play_time.text = msecs_to_text(0)
	_on_delete_button_up()

