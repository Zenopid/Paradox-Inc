extends Control

@export var player: Player 
@onready var settings_scene  = $Settings
@onready var level_label:Label = $Level_Name
@onready var quit_confirmation = $QuitConfirmation

var quitting_to_menu: bool = false 

func enable_menu(level_name):
	player.set_process_input(false)
	set_process_input(true)
	self.show()
	level_label.text = level_name
	get_tree().paused = true 

func _on_resume_pressed():
	self.hide()
	get_tree().paused = false
	set_process_input(false)
	player.set_process_input(true)
	
func _on_settings_pressed():
	settings_scene.show()

func _on_save_and_exit_pressed():
	quit_confirmation.show()
	quitting_to_menu = false

func _on_quit_pressed():
	if !quitting_to_menu:
		get_tree().quit()
	else:
		player.get_parent().enable_menu()
		hide()

func _on_main_menu_pressed():
	quit_confirmation.show()
	quitting_to_menu = true 

func _on_quit_menu_resume_pressed():
	quit_confirmation.hide()

func _input(event):
	if Input.is_action_just_pressed("options"):
		print("options pressed")
		_on_resume_pressed()
