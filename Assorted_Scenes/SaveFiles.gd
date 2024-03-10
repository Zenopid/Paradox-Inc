extends Control

const TOTAL_SAVE_FILES: int = 6

@onready var loading_screen: Control
func _ready():
	var save_files = GlobalScript.get_save_files()
	for i in TOTAL_SAVE_FILES:
		var file_data = save_files["FIle" + str(i)]
		var current_file = get_node("SaveFile" + str(i))
		var current_file_info = current_file.get_node("SaveFileInfo")
		var current_file_options = current_file.get_node("SaveFileOptions")
		current_file_info.get_node("PlayTime").text = file_data["playtime"]
		current_file_info.get_node("CurrentLevel").text = file_data["level_data"]["level_name"]
		
	for i in get_tree().get_nodes_in_group("Start Buttons"):
		i.connect("pressed", Callable(self, "_on_start_button_pressed").bind(i.get_parent().get_parent().name))
	for i in get_tree().get_nodes_in_group("Duplicate Buttons"):
		i.connect("pressed", Callable(self, "_on_duplicate_button_pressed").bind(i.get_parent().get_parent().name))
	for i in get_tree().get_nodes_in_group("Delete Buttons"):
		i.connect("pressed", Callable(self, "_on_delete_button_pressed").bind(i.get_parent().get_parent().name))
	for i in get_tree().get_nodes_in_group("Save Buttons"):
		i.connect("pressed", Callable(self, "_on_start_button_pressed").bind(i.get_parent().get_parent().name))

func _on_start_button_pressed(save_num):
	GlobalScript.load_save_file(save_num)
	if loading_screen:
		loading_screen.show()


