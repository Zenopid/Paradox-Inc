extends Label

var player: Player

func _physics_process(delta):
	if player:
		text = "Position: (" + str(round(player.position.x)) + "," + str(round(player.position.y)) + ")"
	else:
		text = "Finding Player..."
		

func _on_timer_timeout():
	for nodes in get_parent().get_parent().get_parent().get_children():
		if nodes is Player:
			player = nodes
			break
