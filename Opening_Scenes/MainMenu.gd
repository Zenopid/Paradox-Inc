extends Control

var future_scene = preload("res://Stages/future.tscn")
var training_scene = preload("res://Levels/Training.tscn")
var player = preload("res://Character/player.tscn")


func _on_start_pressed():
	var future_instance = future_scene.instantiate()
	disable_menu()
	var spawn_spot = Vector2(future_instance.position.x, future_instance.position.y - 30)
	add_child(future_instance)
	add_player(spawn_spot)

func add_player(pos):
	var player_instance: Player = player.instantiate()
	player_instance.position = pos
	player_instance.set_spawn(pos)
	add_child(player_instance)

func disable_menu():
	for nodes in get_children():
		nodes.visible = false 
		if nodes is Button:
			nodes.disabled = true
			nodes.mouse_filter = Control.MOUSE_FILTER_IGNORE

func enable_menu():
	for nodes in get_children():
		if nodes is Control:
			if nodes is Label == false:
				nodes.visible = true
		if nodes is Button:
			nodes.disabled = false
			nodes.mouse_filter = Control.MOUSE_FILTER_PASS
		else:
			nodes.queue_free()

func _on_training_pressed():
	var training_instance: GenericLevel = training_scene.instantiate()
	disable_menu()
	var spawn_spot = training_instance.get_start_point()
	add_child(training_instance)
	add_player(spawn_spot)
