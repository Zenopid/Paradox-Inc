extends Control

var training_scene = preload("res://Levels/Training.tscn")
var player = preload("res://Character/Player/Scenes/player.tscn")
var camera_path = preload("res://Universal_Scenes/camera.tscn")
var first_level = preload("res://Levels/Act 1/Emergence.tscn")
@onready var settings_scene = $"%Settings"
@onready var end_screen = $"%LevelEnd"
var current_level: GenericLevel

func _ready():
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("level_over", Callable(self, "_on_level_over"))

func _on_level_over():
	end_screen.end_level(current_level)
	current_level.queue_free()
	var player = get_tree().get_first_node_in_group("Players")
	player.queue_free()

func add_player(pos) -> Player: 
	var player_instance = player.instantiate()
	player_instance.position = pos
	player_instance.set_spawn(pos)
	player_instance.set_level( current_level )
	player_instance.add_to_group("Players")
	add_child(player_instance) 
	return player_instance
	

func disable_menu():
	GlobalScript.emit_signal("disabling_menu")
	get_tree().paused = false
	for nodes in get_tree().get_nodes_in_group("Menu"):
		nodes.visible = false
		if nodes is Button:
			nodes.disabled = true
		nodes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var player = get_tree().get_first_node_in_group("Players")

func enable_menu():
	GlobalScript.emit_signal("enabling_menu")
	get_tree().paused = true 
	for nodes in get_tree().get_nodes_in_group("Menu"):
		nodes.visible = true
		if nodes is Button:
			nodes.disabled = false
		nodes.mouse_filter = Control.MOUSE_FILTER_PASS
	var player = get_tree().get_first_node_in_group("Players")
	settings_scene.hide()

func _on_training_pressed():
	var training_instance: GenericLevel = training_scene.instantiate()
	current_level = training_instance
	disable_menu()
	add_child(training_instance)
	var spawn_spot = training_instance.get_start_point()
	add_player(spawn_spot)
	GlobalScript.current_level = "Training"
	

func _on_settings_pressed():
	disable_menu()
	settings_scene.show()
	settings_scene.connect("exiting_settings", Callable(self, "enable_menu"))

func _on_game_over():
	enable_menu() 


func _on_start_pressed():
	disable_menu()
	var emergence_level:GenericLevel = first_level.instantiate()
	add_child(emergence_level)
	current_level = emergence_level
	var spawn_spot = emergence_level.get_start_point()
	var player_instance = add_player(spawn_spot)
	GlobalScript.current_level = "Emergence"
	emergence_level.set_player(player_instance)
	emergence_level.start_level()
	
