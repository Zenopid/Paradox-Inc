extends Label
@export_category("Timeline Colors")
@export var future_color: Color
@export var past_color:Color
@export var extra_color:Color
func init(player: Player):
	var level = player.get_level()
	level.connect("swapped_timeline", Callable(self, "timeline_text"))
	GlobalScript.connect("setting_changed", Callable(self, "_on_setting_changed"))
	timeline_text(level.get_current_timeline())
func _on_setting_changed(setting_name:String, value):
	if setting_name == "show_fps":
		visible = value

func timeline_text(new_text:String):
	text = new_text
	new_text = new_text.to_lower()
	if new_text == "future":
		set("theme_override_colors/font_color", future_color)
	elif new_text == "past":
		set("theme_override_colors/font_color", past_color)
	else:
		set("theme_override_colors/font_color", past_color)
