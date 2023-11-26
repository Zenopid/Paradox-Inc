class_name GenericLevel extends Node

@onready var future: TileMap = get_node("Future")
@onready var past: TileMap = get_node("Past")
@onready var music_player = $BGM

@export var current_timeline: String = "Future"

signal swapped_timeline(new_timeline)

var music_playlist = []

var restarting_level = false

var box_scene = preload("res://Universal_Scenes/Interactables/box.tscn")

func _ready():
	var folder_path = "res://audio/bgm/"
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin() 
		while true:
			var music_file = dir.get_next()
			if music_file == "":
				break
			elif not music_file.begins_with("."):
				if music_file.ends_with(".wav") || music_file.ends_with(".mp3"):
					music_playlist.append(load(folder_path + music_file))
	past.modulate = future.modulate
	match current_timeline:
		"Future":
			for layers in past.get_layers_count():
				past.set_layer_enabled(layers, false)
		"Past":
			for layers in future.get_layers_count():
				future.set_layer_enabled(layers, false)

func _physics_process(delta):
	if Input.is_action_just_pressed("play_music"):
		if music_player.playing:
			music_player.stop()
		else:
			var index = randi() % music_playlist.size()
			music_player.stream = music_playlist[index]
			music_player.play()
	if Input.is_action_just_pressed("swap_timeline"):
		match current_timeline:
			"Future":
				for layers in future.get_layers_count():
					future.set_layer_enabled(layers, false)
				for layers in past.get_layers_count():
					past.set_layer_enabled(layers, true)
				current_timeline = "Past"
			"Past":
				for layers in future.get_layers_count():
					future.set_layer_enabled(layers, true)
				for layers in past.get_layers_count():
					past.set_layer_enabled(layers, false)
				current_timeline = "Future"
		for nodes in get_tree().get_nodes_in_group("Small Objects"):
			if nodes is MoveableObject:
				if nodes.get_paradox_status() == false:
					nodes.swap_status()
		emit_signal("swapped_timeline", current_timeline)
	if Input.is_action_pressed("view_timeline"):
		future.visible = true
		past.visible = true
		match current_timeline:
			"Future":
				future.modulate.a = 0.1
				past.modulate.a = 1
			"Past":
				future.modulate.a = 1
				past.modulate.a = 0.1
	else:
		future.visible = true
		past.visible = true
		if current_timeline == "Future":
			past.visible = false
			future.modulate.a = 1
		else:
			future.visible = false
			past.modulate.a = 1

func get_start_point():
	return $SpawnPoint.position


func _on_spawner_pressed():
	var box_instance = box_scene.instantiate()
	box_instance.position = $BoxSpawnPoint.position
	
	add_child(box_instance)

func get_next_timeline_swap():
	if current_timeline == "Future":
		return "Past"
	else:
		return "Future"

func _on_clear_box_pressed():
	for nodes in get_children():
		if nodes is MoveableObject:
			nodes.queue_free()
