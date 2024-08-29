class_name Training extends GenericLevel

@export var elevator_speed: float = 5

@onready var box_spawn_point:Node2D = $BoxSpawnPoint
@onready var enemy_spawn_point:Node2D = $EnemySpawnerPoint
@onready var speed_slider = $"%Speed_Slider"
@onready var future_puzzle_tilemap = $"%FuturePuzzle"
@onready var paradox_puzzle_tilemap = $"%ParadoxPuzzle"
@onready var past_puzzle_tilemap = $"%PastPuzzle"

@onready var future_player:AnimationPlayer = $"%FutureAnimPlayer"
@onready var past_player:AnimationPlayer = $"%PastAnimPlayer"
@onready var training_ui:CanvasLayer = $"%TrainingUI"

@onready var level_player:AnimationPlayer = $"%LevelAnimPlayer"

@onready var rotate_speed: int = 6
@onready var puzzle_box: Node2D = $"%PuzzleLocation"

func _ready():
	super._ready()
	puzzle_box.position = Vector2(388, -719)
	$"%FuturePuzzle".position = Vector2.ZERO
	$"%PastPuzzle".position = Vector2.ZERO
	$"%ParadoxPuzzle".position = Vector2.ZERO 
	$"%PuzzleSwitch".position = Vector2(87.5, 2.3)
	#level_player.play("MoveElevator")

#func _process(delta):
	#print(Engine.get_frames_per_second())
func _on_setting_changed(new_setting, value):
	pass
	
func _on_spawner_pressed():
	var new_box = load(GlobalScript.BOX_PATH)
	var box_instance = new_box.instantiate()
	box_instance.position = box_spawn_point.position
	add_child(box_instance)
	box_instance.add_to_group("Boxes")
	return box_instance
	
func _on_clear_box_pressed():
	for nodes in get_tree().get_nodes_in_group("Boxes"):
		nodes.kill()

func _on_clear_enemy_pressed():
	for nodes in get_tree().get_nodes_in_group("Training Enemies"):
		nodes.queue_free()

func _on_spawn_enemy_pressed():
	var new_enemy = load(GlobalScript.PARAGHOUL_PATH)
	var enemy_instance: ParaGhoul = new_enemy.instantiate()
	enemy_instance.position = enemy_spawn_point.position
	enemy_instance.add_to_group("Training Enemies")
	var box = _on_spawner_pressed()
	enemy_instance.link_to_object(box)
	box.link_to_object(box)
	add_child(enemy_instance)
	return enemy_instance

func _on_h_slider_value_changed(value: float):
	Engine.time_scale = value

func _on_reset_pressed():
	Engine.time_scale = 1
	speed_slider.value = 1

func _on_rotate_box_right_status_changed(activated:bool):
	if activated:
		future_player.play("RotatePuzzleBox")
	else:
		future_player.pause()

func _on_rotate_box_left_activated(activated:bool):
	if activated:
		future_player.play_backwards("RotatePuzzleBox")
	else:
		future_player.pause()

func _on_move_past_puzzle_pieces_status_changed(new_status):
	if new_status:
		past_player.play_backwards("PuzzlePastSwitch")
	else:
		past_player.pause()

func disable():
	super.disable()
	training_ui.hide()

func enable():
	super.enable()
	training_ui.show()
