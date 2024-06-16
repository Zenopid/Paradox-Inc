extends Control

@export var player: Player

@onready var level_label:Label = $Level_Name
@onready var quit_confirmation = $QuitConfirmation
@onready var resume_button: Button = $"%Resume"
@onready var exit_callable:Callable = Callable(self, "_on_settings_exited" )
@onready var cheat_bar:Control = $"%Cheats"
@onready var cheat_text:LineEdit = $"%CheatName"
var quitting_to_menu: bool = false 
var restarting_level:bool = false 

var previous_cursor


func enable_menu(level_name):
	
	Input.set_custom_mouse_cursor(null)
	GlobalScript.connect("exiting_settings", exit_callable)
	player.set_process_input(false)
	set_process_input(true)
	self.show()
	level_label.text = level_name
	get_tree().paused = true 
	resume_button.grab_focus()

func _on_resume_pressed():
	if player.grapple_enabled:
		Input.set_custom_mouse_cursor(player.grapple.pointer.texture)
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

	if quitting_to_menu:
		GlobalScript.main_menu.enable_menu()
		hide()
	else:
		get_tree().quit()
	GlobalScript.stop_music()
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
	get_tree().paused = true




func _on_enter_cheat_pressed():
	cheat_bar.show()

func _on_close_cheat_screen_pressed():
	cheat_bar.hide()


func _on_cheat_button_pressed():
	var new_text:String = cheat_text.text
	if new_text.contains("tp"):
		var checkpoint = get_tree().get_first_node_in_group("CurrentLevel").get_node("Checkpoints").get_node("Checkpoint" + new_text[new_text.length() - 1])
		if checkpoint:
			player.player_info.global_position = checkpoint.global_position
			player.global_position = checkpoint.global_position
	match new_text:
		"restore_hp":
			player.heal(player.player_info.max_health - player.player_info.health)
		"inf_hp":
			player.player_info.max_health = 999999999
			player.health_bar.init(999999999)
	print("CHEATING with option " + new_text)
