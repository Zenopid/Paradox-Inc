extends Button

func _on_pressed():
	if GlobalScript.get_setting("ui_sfx_enabled"):
		$SFX.play()
