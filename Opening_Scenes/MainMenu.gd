class_name MainMenu extends Control

signal level_selected()

const GHOST_BUTTON_PATH:String = "uid://ddb6v8avcjany"

var training_scene = preload("res://Levels/Training.tscn")
var player = preload("res://Character/Player/Scenes/player.tscn")
var camera_path = preload("res://Universal_Scenes/camera.tscn")
var first_level = preload("res://Levels/Act 1/Emergence.tscn")

@onready var start_button: Button = $"%Start"
@onready var anim_player:AnimationPlayer = $AnimationPlayer

@onready var debug_screen:Panel = $"%Debug_Screen"
@onready var debug_text:Label = $"%Debug_Text"
@onready var debug_timer:Timer = $"%Debug_Timer"
@onready var save_screen:ColorRect = $"%SaveInfo"
@onready var save_file_text:Label = $"%SaveFileText"
@onready var level_select:Control = $"%LevelSelect"
@onready var resume: Button = $"%Resume"
@onready var exit_button:TextureButton = $"%Exit"
@onready var selected_level:String 

@onready var screen_darkener:ColorRect = $"%ScreenDarkener"
@onready var ghost_screen:Control = $"%GhostScreen"

@onready var selected_ghost:String = "Training"
@onready var start_game_on_level_button_pressed:bool = true

@onready var ghost_data:PlayerGhost

func _ready():
	GlobalScript.main_menu = self
	add_to_group("MainMenu")
	GlobalScript.connect("game_over", Callable(self, "_on_game_over"))
	GlobalScript.connect("level_over", Callable(self, "_on_level_over"))
	start_button.grab_focus()
	
	for i in get_tree().get_nodes_in_group("Levels"):
		i.connect("pressed", Callable(self, "start_level").bind(i.name))
	resume.disabled = !GlobalScript.has_save()
	exit_button.disabled = false
	enable_menu()


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
	start_game_on_level_button_pressed = true
	show()
	Engine.time_scale = 1
	GlobalScript.emit_signal("enabling_menu")
	get_tree().paused = true 
	for nodes in get_tree().get_nodes_in_group("Menu"):
		nodes.visible = true
		nodes.mouse_filter = Control.MOUSE_FILTER_PASS
	for nodes in get_tree().get_nodes_in_group("Debug"):
		nodes.visible = GlobalScript.debug_enabled
	resume.disabled = !GlobalScript.has_save()
	set_process_input(true)
	start_button.grab_focus()
	GlobalScript.disable_free_play()
	ghost_screen.hide()
	level_select.hide()
	if ResourceLoader.exists(ghost_data.SAVE_FILE_PATH):
		ghost_data = ResourceLoader.load(ghost_data.SAVE_FILE_PATH)
	

func _on_start_pressed():
	level_select.show()
	exit_button.hide()
	exit_button.disabled = true 
	$"%LevelButtons".get_child(0).grab_focus()
	GlobalScript.disable_free_play()

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

func start_level(level_name:String):
	disable_menu()
	if start_game_on_level_button_pressed:
		GlobalScript.start_level(level_name)
		return
	selected_level = level_name.strip_edges()
	emit_signal("level_selected")

func _on_debug_timer_timeout():
	debug_screen.hide()

func _on_clear_data_pressed():
	debug_screen.show()
	debug_text.text = "Deleting Save..."
	DirAccess.remove_absolute(Player.SAVE_FILE_PATH)
	DirAccess.remove_absolute(GenericLevel.SAVE_FILE_PATH)
	DirAccess.remove_absolute(GlobalScript.SAVE_FILE_PATH)
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
	start_button.grab_focus()
	
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

func _on_free_play_pressed():
	start_game_on_level_button_pressed = true
	_on_start_pressed()
	GlobalScript.enable_free_play()


func _on_time_attack_pressed():
	start_game_on_level_button_pressed  = false
	_on_start_pressed()
	await level_selected
	anim_player.play("GetGhosts")

func init_ghost_buttons():
	GlobalScript.enable_time_trial()
	var ghost_container: VBoxContainer = $"%GhostContainer"

	for i in ghost_data.saved_ghosts[selected_level].keys():
		
		var new_button :ColorRect = load(GHOST_BUTTON_PATH).instantiate()
		ghost_container.add_child(new_button)
		new_button.init(ghost_data, selected_level, str(i))
		new_button.get_node("Race").connect("pressed", Callable(self, "_on_ghost_button_pressed").bind(str(i)))
		var spacer_node:MarginContainer = MarginContainer.new()
		spacer_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		spacer_node.set_custom_minimum_size(Vector2(0, 50))
		ghost_container.add_child(spacer_node)
		
func _on_ghost_button_pressed(ghost_name:String):
	GlobalScript.add_ghost(selected_level, ghost_name)
	GlobalScript.start_level(selected_level)
	
func _on_exit_ghost_screen_pressed():

	screen_darkener.hide()
	ghost_screen.hide()
	GlobalScript.disable_time_trial()
	start_game_on_level_button_pressed = true
	enable_menu()
