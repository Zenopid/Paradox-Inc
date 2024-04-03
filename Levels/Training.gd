extends GenericLevel

@onready var box_spawn_point:Node2D = $BoxSpawnPoint
@onready var enemy_spawn_point:Node2D = $EnemySpawnerPoint
@onready var animation_player = $AnimationPlayer
@onready var speed_slider = $"%Speed_Slider"
@onready var future_puzzle_tilemap = $"%FuturePuzzle"
@onready var past_puzzle_tilemap = $"%PastPuzzle"

@export var box_turn_speed: int = -6
func _ready():
	super._ready()
	GlobalScript.connect("setting_changed", Callable(self, "_on_setting_changed"))
	future_puzzle_tilemap.position = Vector2(388, -719)
	past_puzzle_tilemap.position = Vector2(400, -690)
func _on_setting_changed(new_setting, value):
	pass
	
func _on_spawner_pressed():
	var box_instance = box_scene.instantiate()
	box_instance.position = box_spawn_point.position
	add_child(box_instance)
	box_instance.add_to_group("Boxes")


func _on_clear_box_pressed():
	for nodes in get_tree().get_nodes_in_group("Boxes"):
		nodes.queue_free()

func _on_clear_enemy_pressed():
	for nodes in get_tree().get_nodes_in_group("Darkstalkers"):
		nodes.queue_free()

func _on_spawn_enemy_pressed():
	var enemy_instance = darkstalker_scene.instantiate()
	enemy_instance.position = enemy_spawn_point.position
	enemy_instance.add_to_group("Darkstalkers")
	add_child(enemy_instance)

func _on_h_slider_value_changed(value: float):
	Engine.time_scale = value


func _on_elevator_switch_status_changed(new_status:bool):
	if new_status:
		animation_player.play("Spin Platform")
	else:
		animation_player.pause()


func _on_reset_pressed():
	Engine.time_scale = 1
	speed_slider.value = 1


func _on_rotate_box_left_status_changed(new_status):
	if new_status:
		animation_player.play("PuzzleFutureSwitch")
	else:
		animation_player.stop(true)
		


func _on_rotate_box_right_status_changed(new_status):
	if new_status:
		animation_player.play_backwards("PuzzleFutureSwitch")
	else:
		animation_player.pause()


func _on_move_past_puzzle_pieces_status_changed(new_status):
	if new_status:
		animation_player.play("PuzzlePastSwitch")
	else:
		animation_player.pause()
