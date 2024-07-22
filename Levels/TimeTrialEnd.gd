class_name TimeTrialEndScreen extends Control

signal screen_closed()


@onready var P1_time: Label = $"%P1Time"
@onready var P2_time:Label = $"%P2Time"
@onready var anim_player:AnimationPlayer = $"AnimationPlayer"
@onready var checkpoint_title:Label = $"%CheckpointTitle"
@onready var winner_label:Label = $"%Winner"

var player_one:Player
var player_two:GhostEntity

var player_one_timestamps:PackedInt32Array 
var player_two_timestamps:PackedInt32Array

func end_level():
	player_one = player_one as Player
	player_two = player_two as GhostEntity
	player_one = get_tree().get_first_node_in_group("Players")
	player_two = get_tree().get_first_node_in_group("PlayerGhosts")
	
	player_one_timestamps = player_one.checkpoint_timestamps
	player_two_timestamps = player_two.checkpoints
	
	await get_tree().create_timer(1).timeout
	
	for timestamp:int in player_one_timestamps.size():
		var p1_timestamp:int = player_one_timestamps[timestamp]
		var p2_timestamp:int = player_two_timestamps[timestamp]
		P1_time.text = timestamp_to_text(p1_timestamp)
		P2_time.text = timestamp_to_text(p2_timestamp)
		checkpoint_title.text = "CHECKPOINT " + str(timestamp + 1) + ":"
		if p1_timestamp > p2_timestamp:
			anim_player.play("P1Better")
		else:
			anim_player.play("P2Better")
		await anim_player.animation_finished
	if player_one_timestamps[player_one_timestamps.size() - 1] < player_two_timestamps[player_two_timestamps.size() - 1]:
		winner_label.text = "Player 1"
	else:
		winner_label.text = "Player 2"
	anim_player.play("ShowWinner")
	await anim_player.animation_finished
	$"%PostGameOptions".show()

	
func timestamp_to_text(total_time:int) -> String:
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

func _on_return_button_pressed():
	hide()
	emit_signal('screen_closed')
