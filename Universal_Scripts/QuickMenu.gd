extends Control

@export var player: Player 
@onready var settings_scene  = $Settings
@onready var level_label:Label = $Level_Name
@onready var quit_confirmation = $QuitConfirmation

var quitting_to_menu: bool = false 

func enable_menu(level_name):
	level_label.text = level_name
	get_tree().paused = true 
	show()

func _on_resume_pressed():
	self.hide()
	get_tree().paused = false
	
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

func _on_main_menu_pressed():
	quit_confirmation.show()
	quitting_to_menu = true 

func _on_quit_menu_resume_pressed():
	quit_confirmation.hide()
