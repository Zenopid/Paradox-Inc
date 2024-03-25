class_name GenericLevel extends Node2D


@onready var future: TileMap = get_node("Future")
@onready var past: TileMap = get_node("Past")
@onready var future_tileset: TileSet
@onready var past_tileset: TileSet
@onready var music_player = $BGM
@onready var spawn_point = get_node("SpawnPoint")


@export_enum("Future", "Past") var current_timeline: String = "Future"

signal swapped_timeline(new_timeline)

var music_playlist = []
var level_conditions = {}
var restarting_level = false
var box_scene = preload("res://Universal_Scenes/Interactables/box.tscn")
var darkstalker_scene = preload("res://Enemy/Darkstalker.tscn")

var lock_timeline:bool = false
var lock_music:bool = false

var old_timeline_tileset: TileSet
var current_timeline_tileset: TileSet

var current_player: Player

var player_deaths: int = 0

var timeline_layers = [2,3]
var timeline_masks = [1, 8]
func _ready():
	load_music()
	future_tileset = future.tile_set
	past_tileset = past.tile_set
	var old_timeline = current_timeline
	set_timeline(get_next_timeline_swap())
	set_timeline(old_timeline)
	#for some reason this is needed in order to wall slide. prob some issue 
	#with collision or somethin
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("enabling_menu", Callable(self, "_on_game_over"))
	GlobalScript.connect("disabling_menu", Callable(self, "enable"))
	
func enable():
	show()
	set_physics_process(true)
	set_process(true)
	set_process_input(true)

func disable():
	hide()
	set_physics_process(false)
	set_process(false)
	set_process_input(false)

func _on_game_over():
	self.queue_free()

func _on_player_respawning():
	set_timeline(current_player.respawn_timeline)
	player_deaths += 1

func load_music():
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

func _input(event):
	if Input.is_action_just_pressed("play_music"):
		if music_player.playing:
			music_player.stop()
		else:
			var index = randi() % music_playlist.size()
			music_player.stream = music_playlist[index]
			music_player.play()
		return
	if Input.is_action_just_pressed("swap_timeline"):
		set_timeline(get_next_timeline_swap())
		return
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
			


func set_timeline(new_timeline:String):
	var old_timeline_tilemap: TileMap = get(current_timeline.to_lower())
	var current_timeline_tilemap: TileMap = get(new_timeline.to_lower())
	old_timeline_tileset = old_timeline_tilemap.tile_set
	current_timeline_tileset = current_timeline_tilemap.tile_set
	if current_timeline != new_timeline:
		if !current_timeline_tileset:
			print_debug("No tileset for the timeline " + str(new_timeline))
			return
		current_timeline = new_timeline
		current_timeline_tileset.set_physics_layer_collision_layer(0, 2)
		old_timeline_tileset.set_physics_layer_collision_layer(0, 0)
		current_timeline_tileset.set_physics_layer_collision_layer(1, 4)
		old_timeline_tileset.set_physics_layer_collision_layer(1, 0)
		
		
		old_timeline_tilemap.visible = false
		current_timeline_tilemap.modulate.a = 1
		current_timeline_tilemap.visible = true
#		current_timeline_tilemap.visible = true
#		current_timeline_tilemap.modulate.a = 1
#		old_timeline_tilemap.visible = false
		for nodes in get_tree().get_nodes_in_group("Moveable Object"):
			nodes.swap_status()
		emit_signal("swapped_timeline",current_timeline)
	else:
		for nodes in get_tree().get_nodes_in_group("Timelines"):
			var alt_timeline = nodes.tile_set
			alt_timeline.set_physics_layer_collision_layer(0,2) 
			alt_timeline.set_physics_layer_collision_layer(1,0)
		var starting_timeline = get(current_timeline.to_lower()).tile_set
		starting_timeline.set_physics_layer_collision_layer(0, 2)
		starting_timeline.set_physics_layer_collision_layer(1, 4)
				
func get_start_point():
	return spawn_point.position

func get_next_timeline_swap():
	if current_timeline == "Future":
		return "Past"
	else:
		return "Future"

func get_current_timeline():
	return current_timeline

func save():
	pass
	#virtual method for each level i guess. i hate resources lol

func set_player(new_player):
	current_player = new_player
