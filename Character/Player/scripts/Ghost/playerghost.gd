class_name GhostEntity extends CharacterBody2D

@onready var anim_player:AnimationPlayer = $"%SpriteAnimator"
@onready var sprite:AnimatedSprite2D = $"%Sprite"
@onready var checkpoint_timestamp:Label = $"%CheckpointTimeStamp"

var positions:PackedVector2Array = []
var animations:PackedStringArray = []
var checkpoints: PackedInt32Array = []

var index = 0;

func _ready():
	add_to_group("PlayerGhosts")

func _init():
	set_physics_process(false)
	set_process(false)
	remove_from_group("Players")
	
func set_ghost_info(ghost_info:= {}) :
	
	positions = ghost_info["Locations"]
	animations = ghost_info["Animations"]
	checkpoints = ghost_info["Checkpoint_Timestamps"]


	
func connect_signals():
	GlobalScript.connect("level_over", Callable(self, "_on_level_over"))
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("enabling_menu", Callable(self, "_on_game_over"))
	GlobalScript.connect("disabling_menu", Callable(self, "enable"))
	GlobalScript.connect("save_game_state", Callable(self, "save"))
	GlobalScript.current_level.connect("starting_level", Callable(self, "_on_level_start"))
	
func _on_level_start():
	connect_signals()
	set_physics_process(true)
	set_process(true)
	get_checkpoint_timestamp(0)
	
func _physics_process(delta):
	if index < animations.size():
		if animations[index] != anim_player.get_current_animation():
			anim_player.play( animations[index])
		global_position = positions[index] 
		index += 1;

func get_checkpoint_timestamp(checkpoint_index:int):
	var total_time = checkpoints[checkpoint_index]
	var minutes_played = roundi(total_time / 1000 /60)
	var seconds_played = roundi(total_time / 1000 % 60)
	var msecs_played = roundi(total_time%1000/10)

	set_checkpoint_text(msecs_played, seconds_played, minutes_played)
	return checkpoints[checkpoint_index]

func set_checkpoint_text(msecs_played, seconds_played, minutes_played, ):
	if msecs_played < 10:
			if msecs_played == 0:
				msecs_played = "00"
			else:
				msecs_played = "0" + str(msecs_played)
	if minutes_played < 10:
		minutes_played = "0" + str(minutes_played)
	if seconds_played < 10:
		seconds_played = "0" + str(seconds_played)

	checkpoint_timestamp.text = str(minutes_played) + ":" + str(seconds_played) + ":" + str(msecs_played)
