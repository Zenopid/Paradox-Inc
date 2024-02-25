extends Control

var training_scene = preload("res://Levels/Training.tscn")
var player = preload("res://Character/Player/Scenes/player.tscn")
var camera_path = preload("res://Universal_Scenes/camera.tscn")
var settings_scene = preload("res://Assorted_Scenes/settings.tscn")

var player_instance: Player

func add_player(pos) -> Player:
	player_instance = player.instantiate()
	player_instance.position = pos
	player_instance.set_spawn(pos)
#	player_instance.set_camera(camera)
	add_child(player_instance)
	return player_instance
	

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
		else:
			nodes.queue_free()
		if nodes is Button:
			nodes.disabled = false
			nodes.mouse_filter = Control.MOUSE_FILTER_PASS

func _on_training_pressed():
	var training_instance: GenericLevel = training_scene.instantiate()
	disable_menu()
	var spawn_spot = training_instance.get_start_point()
	add_child(training_instance)
	add_player(spawn_spot)
#	var camera:Camera2DPlus = camera_path.instantiate()
#	var player_path: NodePath = camera.get_path_to(player, true)
#	camera.set_follow_node(player_path)
#	add_child(camera) 
#	print(player_path)
#	camera.enabled = true 
#	print(player_path)
#	camera.set_follow_node(player_path)
#	print(camera.NODE_TO_FOLLOW_PATH)

#func _ready():
#	set_process(false)

#func _process(delta):
#	camera.global_position = player_instance.global_position


func _on_settings_pressed():
	var settings = settings_scene.instantiate()
	add_child(settings)
#	disable_menu()
#	$VBoxContainer/Settings.text = "Not Ready"
#	$VBoxContainer/Settings.disabled = true
