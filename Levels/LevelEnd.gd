extends Control

@export var zero_deaths_color: Color
@export var gold_color: Color
@export var sliver_color: Color
@export var bronze_color: Color


@onready var rating:Label = $"%ScoreRating"
@onready var time:Label = $"%TotalTime"
@onready var deaths:Label = $"%NumberOfDeaths"
@onready var anim_player:AnimationPlayer = $"%Anim_Player"

@onready var sfx = $Sfx
@onready var timer:Timer = $"%Timer"

@onready var return_button:Button = $"%ReturnButton"
@onready var player:Player
var death_count: int 
func end_level():
	var current_level = get_tree().get_first_node_in_group("CurrentLevel")
	return_button.hide()
	get_tree().paused = true
	player = get_tree().get_first_node_in_group("Players")
	player.disable()
	show()
	var minutes = set_time_text()
	var score:int = get_death_score(current_level.player_deaths) + get_time_score(minutes)
	set_rating_text(score)
	anim_player.play("Win")
	await  anim_player.animation_finished
	timer.start()
	await timer.timeout
	return_button.show()

func get_death_score(death_num:int):
	var death_score: int = 0
	deaths.text = str(death_num)
	if death_count <= 0:
		deaths.set("theme_override_colors/font_color", zero_deaths_color)
		death_score += 3
	elif death_count <= 3:
		death_score += 2
	elif death_count <= 5:
		death_score += 1
	return death_score
func get_time_score(minutes) -> int:
	var time_score:int = 0
	if minutes <= 3:
		time_score += 7
	elif minutes <= 7:
		time_score += 4
	elif minutes <= 10:
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
	var menu = get_tree().get_first_node_in_group("Main")
	GlobalScript.emit_signal("game_over")
	hide()
	get_tree().paused = false
