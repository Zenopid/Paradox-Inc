extends Control

var training_scene = preload("res://Levels/Training.tscn")
var player = preload("res://Character/Player/Scenes/player.tscn")
var camera_path = preload("res://Universal_Scenes/camera.tscn")
var first_level = preload("res://Levels/Act 1/Emergence.tscn")
@onready var settings_scene = $Settings

var player_instance: Player
var current_level: GenericLevel

func _ready():
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))


func add_player(pos) -> Player:
	player_instance = player.instantiate()
	player_instance.position = pos
	player_instance.set_spawn(pos)
	player_instance.set_level( current_level )
	add_child(player_instance)
	return player_instance
	

func disable_menu():
	get_tree().paused = false
	for nodes in get_children():
		nodes.visible = false 
		if nodes is Button:
			nodes.disabled = true
			nodes.mouse_filter = Control.MOUSE_FILTER_IGNORE


func enable_menu():
	get_tree().paused = true 
	for nodes in get_children():
		if nodes is Control:
			if nodes is Label == false:
				nodes.visible = true
			if nodes is Button:
				nodes.disabled = false
			nodes.mouse_filter = Control.MOUSE_FILTER_PASS
		else:
			nodes.queue_free()
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
	player_instance.queue_free()
	current_level.queue_free()
	enable_menu()


func _on_start_pressed():
	var emergence_level:GenericLevel = first_level.instantiate()
	current_level = emergence_level
	disable_menu()
	add_child(emergence_level)
	var spawn_spot = emergence_level.get_start_point()
	add_player(spawn_spot)
	GlobalScript.current_level = "Emergence"
