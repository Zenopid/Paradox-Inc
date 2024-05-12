extends Control

@export var player: Player

@onready var level_label:Label = $Level_Name
@onready var quit_confirmation = $QuitConfirmation
@onready var resume_button: Button = $"%Resume"
@onready var exit_callable:Callable = Callable(self, "_on_settings_exited" )
var quitting_to_menu: bool = false 
var restarting_level:bool = false 


func enable_menu(level_name):
	GlobalScript.connect("exiting_settings", exit_callable)
	player.set_process_input(false)
	set_process_input(true)
	self.show()
	level_label.text = level_name
	get_tree().paused = true 
	resume_button.grab_focus()

func _on_resume_pressed():
	self.hide()
	get_tree().paused = false
	set_process_input(false)
	player.set_process_input(true)
	if GlobalScript.is_connected("exiting_settings", exit_callable):
		GlobalScript.disconnect("exiting_settings", exit_callable)
	
func _on_settings_pressed():
	set_process_input(false)
	player.set_process_input(false)
	GlobalScript.enter_settings()

func _on_save_and_exit_pressed():
	quit_confirmation.show()
	quitting_to_menu = false
	restarting_level = false

func _on_quit_pressed():
	if restarting_level:
		GlobalScript.restart_level()
	elif quitting_to_menu:
		GlobalScript.main_menu.enable_menu()
		hide()
	else:
		get_tree().quit()
	if GlobalScript.is_connected("exiting_settings", exit_callable):
		GlobalScript.disconnect("exiting_settings", exit_callable)
		

func _on_main_menu_pressed():
	quit_confirmation.show()
	quitting_to_menu = true

func _on_quit_menu_resume_pressed():
	quit_confirmation.hide()

func _input(event):
	if Input.is_action_just_pressed("options"):
		_on_resume_pressed()

func _on_settings_exited():
	print("you exited?")
	get_tree().paused = true

func _on_restart_pressed():
	restarting_level = true 
	quit_confirmation.show()
