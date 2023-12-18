class_name GenericLevel extends Node

@onready var future: TileMap = get_node("Future")
@onready var past: TileMap = get_node("Past")
@onready var future_tileset: TileSet
@onready var past_tileset: TileSet
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
	future_tileset = future.tile_set
	past_tileset = past.tile_set
	set_timeline(current_timeline)

func _physics_process(delta):
	if Input.is_action_just_pressed("play_music"):
		if music_player.playing:
			music_player.stop()
		else:
			var index = randi() % music_playlist.size()
			music_player.stream = music_playlist[index]
			music_player.play()
	if Input.is_action_just_pressed("swap_timeline"):
		set_timeline(get_next_timeline_swap())
	var old_timeline = get(str(current_timeline.to_lower()))
	var new_timeline = get(str(get_next_timeline_swap().to_lower()))
	if Input.is_action_pressed("view_timeline"):
		if new_timeline:
			new_timeline.visible = true
			new_timeline.modulate.a = 1
		if old_timeline:
			old_timeline.modulate.a = 0.15
	else:
		if new_timeline:
			new_timeline.visible = false
			new_timeline.modulate.a = 1
		if old_timeline:
			old_timeline.modulate.a = 1
#		future.visible = true
#		past.visible = true
#		match current_timeline:
#			"Future":
#				future.modulate.a = 0.1
#				past.modulate.a = 1
#			"Past":
#				future.modulate.a = 1
#				past.modulate.a = 0.1
#	else:
#		future.visible = true
#		past.visible = true
#		if current_timeline == "Future":
#			past.visible = false
#			future.modulate.a = 1
#		else:
#			future.visible = false
#			past.modulate.a = 1

func set_timeline(new_timeline):
	var old_timeline_tileset = get(current_timeline.to_lower() + "_tileset")
	var new_timeline_tileset = get(new_timeline.to_lower() + "_tileset")
	if new_timeline_tileset != past.tile_set and new_timeline_tileset != future.tile_set:
		print("New timeline's tileset isn't past or future.")
	if old_timeline_tileset != past.tile_set and old_timeline_tileset != future.tile_set:
		print("Old timeline's tileset isn't past or future.")
	if current_timeline != new_timeline:
		print("Not current timeline, changing...")
		if !new_timeline_tileset:
			print_debug("No tileset for the timeline " + str(new_timeline))
			return
		for layers in old_timeline_tileset.get_physics_layers_count():
			old_timeline_tileset.set_physics_layer_collision_layer(layers, 0)
		for layers in new_timeline_tileset.get_physics_layers_count():
			new_timeline_tileset.set_physics_layer_collision_layer(layers, 2)
		get(current_timeline.to_lower()).visible = false
		current_timeline = new_timeline 
		print(current_timeline)
		get(current_timeline.to_lower()).modulate.a = 1
		get(current_timeline.to_lower()).visible = true
		for nodes in get_tree().get_nodes_in_group("Small Objects"):
			if nodes is MoveableObject:
				if nodes.get_paradox_status() == false:
					nodes.swap_status()
		emit_signal("swapped_timeline",current_timeline)
	else:
		for nodes in get_children():
			if nodes is TileMap:
				var alt_timeline = nodes.tile_set
				for layers in alt_timeline.get_physics_layers_count():
					alt_timeline.set_physics_layer_collision_layer(layers,0)
		var starting_timeline = get(current_timeline.to_lower())
		for layers in starting_timeline.tile_set.get_physics_layers_count():
			starting_timeline.tile_set.set_physics_layer_collision_layer(layers, 2)

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

func get_current_timeline():
	return current_timeline
