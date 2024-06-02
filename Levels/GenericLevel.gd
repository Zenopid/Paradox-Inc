class_name GenericLevel extends Node2D


const SAVE_FILE_PATH:String = "user://save_info/level_data.tres"

@export var sliver_deaths:int = 3
@export var bronze_deaths:int = 5


@export var bronze_time: float = 5
@export var sliver_time:float = 3
@export var gold_time:float = 1

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

var level_info: LevelInfo = LevelInfo.new()

signal swapped_timeline(new_timeline:String)
signal starting_level()
signal level_over()


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
	level_info.level_name = self.name

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
		GlobalScript.end_level()

func _on_swapped_timeline(new_timeline):
	pass

func start_level():
	current_player.connect("respawning", Callable(self, "_on_player_respawning"))
	emit_signal("starting_level")

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
	set_timeline(current_player.player_info.respawn_timeline)
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
	if Input.is_action_just_pressed("swap_timeline"):
		if !lock_timeline:
			set_timeline(get_next_timeline_swap())
			return
	
func _physics_process(delta):
	pass

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
			paradox.remove_from_group("Past")
			paradox.remove_from_group("Future")
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
	#bronze_time = bronze_time
	#sliver_time = sliver_time
	#gold_time = gold_time
#
	#var packed_level_scene = PackedScene.new()
	#packed_level_scene.pack(self)
	#var error = ResourceSaver.save(packed_level_scene, SAVE_FILE_PATH)
	#assert(error == 0, "Error " + str(error) + " occured when saving level")
	ResourceSaver.save(level_info, SAVE_FILE_PATH)
	return {}

func load_from_file():
	level_info = ResourceLoader.load(SAVE_FILE_PATH)

func set_player(new_player):
	current_player = new_player

func get_endscreen_info():
	var endscreen_info = {
		"SliverDeaths": sliver_deaths,
		"BronzeDeaths": bronze_deaths,
		"BronzeTime": bronze_time,
		"SliverTime":sliver_time,
		"GoldTime":gold_time
	}
