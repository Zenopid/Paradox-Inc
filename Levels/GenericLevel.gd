class_name GenericLevel extends Node2D

@export var past_paradox_color: Color
@export var future_paradox_color: Color
@export var exit_portal: Area2D
@onready var future: TileMap = $"%Future"
@onready var past: TileMap = $"%Past"
@onready var paradoxes:Node2D = $"%Paradoxes"
@onready var future_tileset: TileSet
@onready var past_tileset: TileSet
@onready var music_player = $BGM
@onready var spawn_point = get_node("SpawnPoint")
@onready var future_nav: NavigationRegion2D
@onready var past_nav: NavigationRegion2D


@export_enum("Future", "Past") var current_timeline: String = "Future"

signal swapped_timeline(new_timeline:String)
signal starting_level()

const UNFCOUSED_TIMELINE_MODULATE: float = 0.35

var music_playlist = []
var level_conditions = {}
var restarting_level = false

var lock_timeline:bool = false
var lock_music:bool = false

var old_timeline_tileset: TileSet
var current_timeline_tileset: TileSet

var current_player: Player

var player_deaths: int = 0

func _ready():
	load_music()
	future_tileset = future.tile_set
	past_tileset = past.tile_set
	init_timeline()
	connect_signals()
	self.add_to_group("CurrentLevel")

func connect_signals():
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("enabling_menu", Callable(self, "_on_game_over"))
	GlobalScript.connect("disabling_menu", Callable(self, "enable"))
	if !is_connected("swapped_timeline", Callable(self, "_on_swapped_timeline")):
		connect("swapped_timeline", Callable(self, "_on_swapped_timeline"))
	if exit_portal:
		exit_portal.connect("body_entered", Callable(self, "_on_exit_portal_entered"))

func _on_exit_portal_entered(body):
	if body is Player:
		GlobalScript.emit_signal("level_over")

func _on_swapped_timeline(new_timeline):
	pass

func start_level():
	current_player.connect("respawning", Callable(self, "_on_player_respawning"))

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
#	if Input.is_action_just_pressed("play_music"):
#		if music_player.playing:
#			music_player.stop()
#		else:
#			var index = randi() % music_playlist.size()
#			music_player.stream = music_playlist[index]
#			music_player.play()
#		return
	if Input.is_action_just_pressed("swap_timeline"):
		if !lock_timeline:
			set_timeline(get_next_timeline_swap())
			return
#	var old_timeline = get(str(current_timeline.to_lower()))
#	var new_timeline = get(next_timeline.to_lower())
#	if Input.is_action_pressed("view_timeline"):
#		if next_timeline:
#			new_timeline.visible = true 
#			new_timeline.modulate.a = 0.15
#	else:
#		if new_timeline:
#			new_timeline.visible = false
#			new_timeline.modulate.a = 1
#
func set_timeline(new_timeline:String):
	var old_timeline_tilemap: TileMap = get(current_timeline.to_lower())
	var current_timeline_tilemap: TileMap = get(new_timeline.to_lower())
	if current_timeline != new_timeline:
		if !current_timeline_tilemap:
			print_debug("No tilemap for the timeline " + str(new_timeline))
			return
		for nodes in get_tree().get_nodes_in_group(new_timeline.capitalize()):
			nodes.modulate.a = 1
		for nodes in get_tree().get_nodes_in_group(current_timeline.capitalize()):
			nodes.modulate.a = UNFCOUSED_TIMELINE_MODULATE
		current_timeline = new_timeline
		emit_signal("swapped_timeline",current_timeline)


func init_timeline():
	var timeline = current_timeline.to_lower()
	for nodes in get_tree().get_nodes_in_group("Timelines"):
		nodes.modulate.a = UNFCOUSED_TIMELINE_MODULATE
	for paradox in get_tree().get_nodes_in_group("Paradoxes"):
			paradox.modulate.a = 1
	get(timeline).modulate.a = 1

func get_start_point():
	return spawn_point.position

func get_next_timeline_swap():
	if current_timeline == "Future":
		return "Past"
	else:
		return "Future"

func get_current_timeline():
	return current_timeline

func save() -> Dictionary:
	var save_dict = {
		"level_conditions": level_conditions,
		"current_timeline": current_timeline,
		"music_playlist": music_playlist,
		"name": name,
		"player_deaths": player_deaths,
	}
	SaveSystem.set_var("CurrentLevel", save_dict)
	return save_dict
	# return it for level specfic save functions 
	
func load_from_file():
	var save_data = SaveSystem.get_var("CurrentLevel")
	if save_data:
		for i in save_data.keys():
			set(i, save_data[i])
func set_player(new_player):
	current_player = new_player
