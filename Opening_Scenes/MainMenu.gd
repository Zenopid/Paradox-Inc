extends Control

var training_scene = preload("res://Levels/Training.tscn")
var player = preload("res://Character/Player/Scenes/player.tscn")
var camera_path = preload("res://Universal_Scenes/camera.tscn")
var first_level = preload("res://Levels/Act 1/Emergence.tscn")
@onready var settings_scene:Control = $"%Settings"
@onready var end_screen:Control = $"%LevelEnd"

@onready var start_button: Button = $"%Start"

@onready var debug_screen:Panel = $"%Debug_Screen"
@onready var debug_text:Label = $"%Debug_Text"
@onready var debug_timer:Timer = $"%Debug_Timer"
@onready var save_screen:ColorRect = $"%SaveInfo"
@onready var save_file_text:Label = $"%SaveFileText"
@onready var level_select:Control = $"%LevelSelect"
var current_level: GenericLevel
const LEVEL_PATHS = {
	"Emergence" = "uid://2ixcpeisj8it",
	"Training" = "uid://bdka6oxl4bhmn"
}
func _ready():
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("level_over", Callable(self, "_on_level_over"))
	start_button.grab_focus()
	
	for i in get_tree().get_nodes_in_group("Levels"):
		i.connect("pressed", Callable(self, "start_level").bind(i.name))
	
func _on_level_over():
	end_screen.end_level(current_level)
	current_level.queue_free()
	var player_instance = get_tree().get_first_node_in_group("Players")
	player_instance.queue_free()

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
		nodes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for nodes in get_tree().get_nodes_in_group("Level Select"):
		nodes.visible = false
		nodes.mouse_filter = Control.MOUSE_FILTER_PASS
	for nodes in get_tree().get_nodes_in_group("Debug"):
		nodes.visible = false
	set_process_input(false)

func enable_menu():
	GlobalScript.emit_signal("enabling_menu")
	get_tree().paused = true 
	for nodes in get_tree().get_nodes_in_group("Menu"):
		nodes.visible = true
		nodes.mouse_filter = Control.MOUSE_FILTER_PASS
	for nodes in get_tree().get_nodes_in_group("Debug"):
		nodes.visible = false
	settings_scene.hide()
	set_process_input(true)

func _on_start_pressed():
	level_select.show()
#	start_level("Emergence")

func _on_settings_pressed():
	disable_menu()
	settings_scene.show()
	if !settings_scene.is_connected("exiting_settings", Callable(self, "enable_menu")):
		settings_scene.connect("exiting_settings", Callable(self, "enable_menu"))

func _on_game_over():
	enable_menu() 

func _input(event):
	if Input.is_action_just_pressed("start_debug"):
		GlobalScript.debug_enabled = !GlobalScript.debug_enabled
		if GlobalScript.debug_enabled:
			debug_text.text = "Debug mode has been enabled."
			for nodes in get_tree().get_nodes_in_group("Debug"):
				nodes.show()
		else:
			debug_text.text = "Debug mode has been disabled."
			for nodes in get_tree().get_nodes_in_group("Debug"):
				nodes.hide()
		debug_screen.show()
		debug_timer.start()
		

func start_level(level:String):
	disable_menu()
	var level_path: String = LEVEL_PATHS[level]
	var new_level = load(level_path)
	current_level = new_level.instantiate()
	current_level.add_to_group("CurrentLevel")
	add_child(current_level)
	var spawn_point = current_level.get_start_point()
	var player_instance = add_player(spawn_point)
	GlobalScript.current_level = current_level
	current_level.set_player(player_instance)
	current_level.start_level()
	GlobalScript.load_game()

func _on_debug_timer_timeout():
	debug_screen.hide()


func _on_clear_data_pressed():
	SaveSystem.delete_all()
	debug_text.text = "Deleted all save data."
	debug_screen.show()
	debug_timer.start()

func _on_retrieve_save_pressed():
	var folder_path = "user://save_data.sav"
	var file = FileAccess.open(folder_path, FileAccess.READ_WRITE)
	var content  = file.get_as_text()
	var error = FileAccess.get_open_error()
	if error == 0:
		save_file_text.text = content
		file.close()
		save_screen.show()

func _on_save_info_back_button_pressed():
	save_screen.hide()

func _on_select_back_button_pressed():
	level_select.hide()
