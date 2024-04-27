class_name MainMenu extends Control

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
@onready var resume: Button = $"%Resume"
@onready var exit_button:TextureButton = $"%Exit"
var current_level: GenericLevel

func _ready():
	GlobalScript.main_menu = self
	add_to_group("MainMenu")
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("level_over", Callable(self, "_on_level_over"))
	start_button.grab_focus()
	
	for i in get_tree().get_nodes_in_group("Levels"):
		i.connect("pressed", Callable(self, "start_level").bind(i.name))
	resume.disabled = !GlobalScript.has_save()

func _on_level_over():
	end_screen.end_level()
	if current_level:
		current_level.queue_free()
	var player_instance = get_tree().get_first_node_in_group("Players")
	player_instance.queue_free()
	
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
		nodes.visible = GlobalScript.debug_enabled
	resume.disabled = !GlobalScript.has_save()
	settings_scene.hide()
	set_process_input(true)

func _on_start_pressed():
	level_select.show()
	exit_button.hide()
	exit_button.disabled = true 
#	start_level("Emergence")

func _on_settings_pressed():
	disable_menu()
	GlobalScript.enter_settings()
	
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

#	GlobalScript.load_game()

func start_level(level_name):
	disable_menu()
	GlobalScript.start_level(level_name)

func _on_debug_timer_timeout():
	debug_screen.hide()

func _on_clear_data_pressed():
	SaveSystem.delete_all()
	var save_file = get_save()
	debug_screen.show()
	debug_text.text = "Deleting Save..."
	DirAccess.remove_absolute(SaveSystem.default_file_path)
	debug_text.text = "Deleted Save File."
	debug_timer.start()
	resume.disabled = true

func _on_retrieve_save_pressed():
	var file = get_save()
	if file:
		var content  = file.get_as_text()
		save_screen.show()
		return
	debug_text.text = "No save data found."
	debug_screen.show()
	debug_timer.start()

func get_save():
	var file = FileAccess.open(SaveSystem.default_file_path, FileAccess.READ_WRITE)
	if file:
		if FileAccess.get_open_error() == 0:
			return file
	return null

func _on_save_info_back_button_pressed():
	save_screen.hide()
	enable_menu()

func _on_resume_pressed():
	if GlobalScript.has_save():
		disable_menu()
		GlobalScript.load_game()
	else:
		resume.disabled = true 

func _on_exit_button_pressed():
	get_tree().quit()


func _on_level_select_return_button_pressed():
	exit_button.disabled = false
	exit_button.show()
	level_select.hide()
