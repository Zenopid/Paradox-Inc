extends Enemy

func _on_enemy_sphere_body_entered(body):
	print(body)
	if body is Enemy:
		enemy_sphere_shape.debug_color = detection_color
		enemy_close = true

func _on_enemy_sphere_body_exited(body):
	print(body)
	if body is Enemy:
		enemy_sphere_shape.debug_color = no_detection_color
		enemy_close = false
