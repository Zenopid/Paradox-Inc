extends GenericLevel

@onready var box_spawn_point:Node2D = $BoxSpawnPoint
@onready var enemy_spawn_point:Node2D = $EnemySpawnerPoint
@onready var animation_player = $AnimationPlayer
func _on_spawner_pressed():
	var box_instance = box_scene.instantiate()
	box_instance.init(current_timeline, self)
	box_instance.position = box_spawn_point.position
	add_child(box_instance)
	box_instance.add_to_group("Boxes")
	connect("swapped_timeline", Callable(box_instance,"swap_state"))

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
