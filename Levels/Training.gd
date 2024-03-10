extends GenericLevel

@onready var box_spawn_point = $BoxSpawnPoint
@onready var enemy_spawn_point = $EnemySpawnerPoint

func _on_spawner_pressed():
	var box_instance = box_scene.instantiate()
	box_instance.init(current_timeline, self)
	box_instance.position = box_spawn_point.position
	add_child(box_instance)
	connect("swapped_timeline", Callable(box_instance,"swap_state"))

func _on_clear_box_pressed():
	for nodes in get_children():
		if nodes is MoveableObject:
			nodes.queue_free()

func _on_clear_enemy_pressed():
	for nodes in get_children():
		if nodes is Enemy:
			nodes.queue_free()

func _on_spawn_enemy_pressed():
	var enemy_instance = darkstalker_scene.instantiate()
	enemy_instance.position = enemy_spawn_point.position
	add_child(enemy_instance)
	
	
