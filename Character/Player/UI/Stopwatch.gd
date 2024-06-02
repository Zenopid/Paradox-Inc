extends Label

@export var player: Player

@export var better_than_ghost_time_color: Color
@export var worse_than_ghost_time_color:Color

var start_time: int = 0
var total_time: int

func _ready() -> void:
	start_time = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	#warning-ignore: Integer
	if GlobalScript.time_trial_enabled:
		if GlobalScript.get_current_ghost().get_checkpoint_timestamp(player.get_checkpoints_reached()) < total_time:
			set("theme_override_colors/font_color", better_than_ghost_time_color )
		else:
			set("theme_override_colors/font_color", worse_than_ghost_time_color )
	total_time = Time.get_ticks_msec() - start_time
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

	text = str(minutes_played) + ":" + str(seconds_played) + ":" + str(msecs_played)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func get_total_time():
	return total_time
