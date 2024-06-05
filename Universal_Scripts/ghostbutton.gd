extends ColorRect


var ghost_info
var selected_level:String
var selected_ghost:String

func init(ghost_data: PlayerGhost, level_name:String, ghost_name:String):
	ghost_info = ghost_data.saved_ghosts[level_name][ghost_name] 
	selected_level = level_name
	selected_ghost = ghost_name
	$Title.text = ghost_name.capitalize().strip_edges()
	var checkpoint_locations:PackedInt32Array = ghost_info["Checkpoint_Timestamps"]
	$Time.text = parse_time(checkpoint_locations[checkpoint_locations.size() - 1])
	$AnimationPlayer.play("ShowCard")

func parse_time(total_time: int) -> String:
	#warning-ignore: Integer
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

func _on_delete_pressed():
	ghost_info.saved_ghosts[selected_level].erase(selected_ghost)
	ghost_info.save_ghost_data()
	queue_free()
