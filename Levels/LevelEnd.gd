class_name EndScreen extends Control

signal screen_closed()

@export var zero_deaths_color: Color
@export var gold_color: Color
@export var sliver_color: Color
@export var bronze_color: Color


@onready var screen_darkener:ColorRect = $"%ScreenDarkener"
@onready var rating:Label = $"%ScoreRating"
@onready var time:Label = $"%TotalTime"
@onready var deaths:Label = $"%NumberOfDeaths"
@onready var anim_player:AnimationPlayer = $"%Anim_Player"

@onready var sfx = $Sfx

@onready var return_button:Button = $"%ReturnButton"
@onready var player:Player

@onready var ghost_popup:Control = $"%GhostScreen"
@onready var ghost_name:LineEdit = $"%GhostName"
@onready var save_ghost: Button = $"%Save"
@onready var hide_ghost_popup:TextureButton = $"%CloseGhostCreator"

var death_count: int 
var bronze_deaths: int = 5
var sliver_deaths: int = 3

var bronze_time: int = 3
var sliver_time: int = 7
var gold_time:int = 10

var current_level:GenericLevel

func get_level_info():
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
	var level_info = current_level.get_endscreen_info()
	for info in level_info.keys():
		if info in self:
			set(info, level_info[info])
		else:
			push_error("Couldn't find property " + info + " in the provided dictionary. ")

func end_level():
	current_level = get_tree().get_first_node_in_group("CurrentLevel")
	return_button.hide()
	get_tree().paused = true
	player = get_tree().get_first_node_in_group("Players")
	player.disable()
	show()
	var minutes = set_time_text()
	var score:int = get_death_score(current_level.player_deaths) + get_time_score(minutes)
	set_rating_text(score)
	anim_player.play("Win")
	await anim_player.animation_finished
	return_button.show()

func get_death_score(death_num:int):
	var death_score: int = 0
	deaths.text = str(death_num)
	if death_count <= 0:
		deaths.set("theme_override_colors/font_color", zero_deaths_color)
		death_score += 3
	elif death_count <= sliver_deaths:
		death_score += 2
	elif death_count <= bronze_deaths:
		death_score += 1
	return death_score
	
func get_time_score(minutes) -> int:
	var time_score:int = 0
	if minutes <= gold_time:
		time_score += 7
	elif minutes <= sliver_time:
		time_score += 4
	elif minutes <= gold_time:
		time_score += 1
	return time_score
		
func set_rating_text(score):
	if score >= 10:
		rating.set("theme_override_colors/font_color", gold_color)
		rating.text = "Acceptable"
		
	elif score >= 7:
		rating.set("theme_override_colors/font_color", sliver_color)
		rating.text = "Inefficent"
	else:
		rating.set("theme_override_colors/font_color", bronze_color)
		rating.text = "Inadequate"
		
func set_time_text():
	var total_time = player.stopwatch.get_total_time()
	var minutes_played = roundi(total_time / 1000 /60)
	var seconds_played = roundi(total_time / 1000 % 60)
	var msecs_played = roundi(total_time%1000/10)
	time.text = str(minutes_played) + ":" + str(seconds_played) + ":" + str(msecs_played)
	return minutes_played
	
func _on_return_button_pressed():
	hide()
	emit_signal('screen_closed')

func _on_create_ghost_pressed():
	anim_player.play("OpenGhostScreen")

func _on_save_ghost_pressed():
	var ghost:String = ghost_name.text
	if !ghost.is_empty():
		GlobalScript.ghost_data.add_ghost_data(ghost)
		print("Saved ghost " + ghost)
		anim_player.play("GhostSaved")

func _on_close_ghost_creator_pressed():
	anim_player.play_backwards("OpenGhostScreen")
