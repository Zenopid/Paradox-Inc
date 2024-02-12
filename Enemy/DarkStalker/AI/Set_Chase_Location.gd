extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var object = actor.get_raycast("LOS").get_collider()
	if object:
		if object is Player:
			blackboard.set_value("chase_location", object.position)
			return SUCCESS
	return FAILURE

