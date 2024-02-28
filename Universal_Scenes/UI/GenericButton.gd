extends Button

func _on_pressed():
	if GlobalScript.audio_settings.ui_sfx_enabled:
		$SFX.play()
