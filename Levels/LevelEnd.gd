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
func end_level(current_level: GenericLevel):
	get_tree().paused = true
	var player:Player = current_level.current_player
	if !player:
		player = get_tree().get_first_node_in_group("Players")
	self.show()
	var total_time = player.stopwatch.get_total_time()
	var minutes_played = roundi(total_time / 1000 /60)
	var seconds_played = roundi(total_time / 1000 % 60)
	var msecs_played = roundi(total_time%1000/10)
	time.text = str(minutes_played) + ":" + str(seconds_played) + ":" + str(msecs_played)
	
	var score = 0
	if minutes_played <= 3:
		score += 7
	elif minutes_played <= 7:
		score += 4
	elif minutes_played <= 10:
		score += 1
	
	var death_count = current_level.player_deaths
	if death_count <= 0:
		deaths.set("theme_override_colors/font_color", zero_deaths_color)
		score += 3
	elif death_count <= 3:
		score += 2
	elif death_count <= 5:
		score += 1
	
	if score >= 10:
		rating.set("theme_override_colors/font_color", gold_color)
		rating.text = "Acceptable"
		
	elif score >= 7:
		rating.set("theme_override_colors/font_color", sliver_color)
		rating.text = "Inefficent"
	else:
		rating.set("theme_override_colors/font_color", bronze_color)
		rating.text = "Inadequate"
		
	anim_player.play("Win")
	await  anim_player.animation_finished
	timer.start()
	await timer.timeout
	get_tree().paused = false
	hide()
	print("we done now")



