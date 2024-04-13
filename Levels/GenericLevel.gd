class_name GenericLevel extends Node2D

@export var past_paradox_color: Color
@export var future_paradox_color: Color

@onready var future: Timeline = get_node("Future")
@onready var past: Timeline = get_node("Past")
@onready var paradoxes:Node2D = $"%Paradoxes"
@onready var future_tileset: TileSet
@onready var past_tileset: TileSet
@onready var music_player = $BGM
@onready var spawn_point = get_node("SpawnPoint")

@export_enum("Future", "Past") var current_timeline: String = "Future"

signal swapped_timeline(new_timeline:String)
signal starting_level()

const UNFCOUSED_TIMELINE_MODULATE: float = 0.2 

var music_playlist = []
var level_conditions = {}
var restarting_level = false
var box_scene = load(GlobalScript.BOX_PATH)
var darkstalker_scene = load(GlobalScript.DARKSTALKER_PATH)

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
#	past.tile_set.set_physics_layer_collision_layer(0, 512)
#	past.tile_set.set_physics_layer_collision_layer(1, 2048)
#	future_tileset.set_physics_layer_collision_layer(0, pow(GlobalScript.collision_values.GROUND_FUTURE, 2))
#	future_tileset.set_physics_layer_collision_layer(1, pow(GlobalScript.collision_values.WALL_FUTURE, 2))
#	past_tileset.set_physics_layer_collision_layer(0, pow(GlobalScript.collision_values.GROUND_PAST, 2))
#	past_tileset.set_physics_layer_collision_layer(1, pow(GlobalScript.collision_values.WALL_PAST, 2))
#	var old_timeline = current_timeline
#	set_timeline(get_next_timeline_swap())
#	set_timeline(old_timeline)
#	set_timeline(get_next_timeline_swap())
#	set_timeline(old_timeline)
	#for some reason this is needed in order to disable the inverse timeline of current. prob some issue 
	#with collision or somethin
	init_timeline()
	connect_signals()
	self.add_to_group("CurrentLevel")
#	past_tileset.set_physics_layer_collision_layer(0, pow(GlobalScript.collision_values.GROUND_PAST, 2))
#	past_tileset.set_physics_layer_collision_layer(1, pow(GlobalScript.collision_values.WALL_PAST, 2))
#	print(past_tileset.get_physics_layer_collision_layer(0))
#	print(pow(GlobalScript.collision_values.GROUND_PAST, 2))
#	assert(past_tileset.get_physics_layer_collision_layer(0) == pow(GlobalScript.collision_values.GROUND_PAST, 2), "The ground in the past aint working")
#	assert(past_tileset.get_physics_layer_collision_layer(1) == pow(GlobalScript.collision_values.WALL_PAST, 2), "The walls in the past aint working")
	
func connect_signals():
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("enabling_menu", Callable(self, "_on_game_over"))
	GlobalScript.connect("disabling_menu", Callable(self, "enable"))
	if !is_connected("swapped_timeline", Callable(self, "_on_swapped_timeline")):
		connect("swapped_timeline", Callable(self, "_on_swapped_timeline"))

func _on_swapped_timeline(new_timeline):
	pass

func start_level():
	current_player.connect("respawning", Callable(self, "_on_player_respawning"))
	#connect("swapped_timeline", Callable(current_player, "_on_swapped_timeline"))

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
#	old_timeline_tileset = old_timeline_tilemap.tile_set
#	current_timeline_tileset = current_timeline_tilemap.tile_set
	if current_timeline != new_timeline:
		if !current_timeline_tilemap:
			print_debug("No tilemap for the timeline " + str(new_timeline))
			return
		old_timeline_tilemap.modulate.a = UNFCOUSED_TIMELINE_MODULATE 
		current_timeline_tilemap.modulate.a = 1
		current_timeline = new_timeline
#		future_tileset.set_physics_layer_collision_mask(0, GlobalScript.collision_values.GROUND_FUTURE)
#		future_tileset.set_physics_layer_collision_mask(1, GlobalScript.collision_values.WALL_FUTURE)
#		past_tileset.set_physics_layer_collision_mask(0, GlobalScript.collision_values.GROUND_PAST)
#		past_tileset.set_physics_layer_collision_mask(1, GlobalScript.collision_values.WALL_PAST)
#		for nodes in get_tree().get_nodes_in_group("Moveable Object"):
#			nodes.swap_state(new_timeline)
		emit_signal("swapped_timeline",current_timeline)
#		for nodes in get_tree().get_nodes_in_group("Paradoxes"):
#			var alt_timeline = nodes.tile_set
##			alt_timeline.set_physics_layer_collision_layer(0,pow(GlobalScript.collision_values.GROUND, 2)) 
##			alt_timeline.set_physics_layer_collision_layer(1, pow(GlobalScript.collision_values.WALL, 2))
#			alt_timeline.set_physics_layer_collision_layer(0, pow(GlobalScript.collision_values.GROUND_PARADOX, 2))
#			alt_timeline.set_physics_layer_collision_layer(1, pow(GlobalScript.collision_values.WALL_PARADOX, 2))
#			#alt_timeline.set_phy
#			nodes.modulate.a = 1

func init_timeline():
	var timeline = current_timeline.to_lower()
	for nodes in get_tree().get_nodes_in_group("Timelines"):
#		print(nodes.name + " is the name of the current timeline")
#		print("-------------------------------------------------")
#		print(nodes.get_groups())
#		print("-------------------------------------------------")
		if !nodes.is_paradox():
#			alt_timeline.set_physics_layer_collision_layer(0,pow(GlobalScript.collision_values.GROUND, 2))
#			alt_timeline.set_physics_layer_collision_layer(1,pow(GlobalScript.collision_values.WALL, 2))
			nodes.modulate.a = UNFCOUSED_TIMELINE_MODULATE
	for paradox in get_tree().get_nodes_in_group("Paradoxes"):
#		print(paradox.name + " is the name of the current timeline")
		if paradox.is_paradox() and !paradox.is_in_group("Timelines"):
#			print("-------------------------------------------------")
#			print(paradox.get_groups())
#			print("-------------------------------------------------")
			
			paradox.tile_set.set_physics_layer_collision_layer(0, 2560)
			paradox.tile_set.set_physics_layer_collision_layer(1, 1024 + 2048)
#			alt_timeline.set_physics_layer_collision_layer(0,pow(GlobalScript.collision_values.GROUND, 2)) 
#			alt_timeline.set_physics_layer_collision_layer(1, pow(GlobalScript.collision_values.WALL, 2))
#		alt_timeline.set_physics_layer_collision_layer(0, (pow(GlobalScript.collision_values.GROUND_PAST, 2)) + pow(GlobalScript.collision_values.GROUND_FUTURE, 2))
#		alt_timeline.set_physics_layer_collision_layer(1, (pow(GlobalScript.collision_values.WALL_FUTURE, 2)) + pow(GlobalScript.collision_values.WALL_PAST, 2))
		#alt_timeline.set_phy
			paradox.modulate.a = 1
		
#	future_tileset.set_physics_layer_collision_mask(0, GlobalScript.collision_values.GROUND_FUTURE)
#	future_tileset.set_physics_layer_collision_mask(1, GlobalScript.collision_values.WALL_FUTURE)
#	past_tileset.set_physics_layer_collision_mask(0, GlobalScript.collision_values.GROUND_PAST)
#	past_tileset.set_physics_layer_collision_mask(1, GlobalScript.collision_values.WALL_PAST)
#	var starting_timeline = get(current_timeline.to_lower()).tile_set
#	starting_timeline.set_physics_layer_collision_layer(0, pow(GlobalScript.collision_values.GROUND, 2))
#	starting_timeline.set_physics_layer_collision_layer(1, pow(GlobalScript.collision_values.WALL, 2))

	get(timeline).modulate.a = 1
#	if paradoxes:
#		if timeline == "future":
#			paradoxes.modulate = future_paradox_color
#		else:
#			paradoxes.modulate = past_paradox_color

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
	var save_dict = {
		"level_conditions": level_conditions,
		"current_timeline": current_timeline,
		"music_playlist": music_playlist,
		"name": name
	}
	SaveSystem.set_var("current_level", save_dict)
	#gotta return it for level specfic save functions 
	#virtual method for each level i guess. i hate resources lol
func load_from_file():
	var save_data = SaveSystem.get_var(self.name)
	if save_data:
		for i in save_data.keys():
			set(i, save_data[i])
func set_player(new_player):
	current_player = new_player
