class_name OutOfBounds extends Area2D

@export var damage:int = 25

func _on_body_entered(body):
	if body is Player:
		body.damage(damage)
		body.respawn()
	else:
		body.queue_free()


func set_debug_color(color: Color):
	$CollisionShape2D.debug_color = color


func save():
	var save_dict = {
		"damage": damage,
		"position": {
			"x": position.x,
			"y": position.y
		}
	}
	return save_dict
