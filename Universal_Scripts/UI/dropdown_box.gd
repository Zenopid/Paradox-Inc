extends OptionButton

signal resolution_changed(new_resolution)
var values

func _update_selected_item(item_text: String) -> void:
	if item_text.contains("x"):
		values = item_text.split_floats("x")
		emit_signal("resolution_changed", Vector2i(int(values[0]), int(values[1])) )


func _on_OptionButton_item_selected(index: int) -> void:
	_update_selected_item(get_item_text(index))
