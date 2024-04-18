extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.sprite.flip_h = !actor.sprite.flip_h
	actor.hitsparks.scale.x *= -1
	var los:RayCast2D = actor.get_raycast("LOS")
	if actor.sprite.flip_h:
		los.scale.x = -1
	else:
		los.scale.x = 1
	los.unlock_view()
	
	return SUCCESS
