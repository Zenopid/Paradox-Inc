extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var object = actor.get_raycast("LOS").get_collider()
	if object:
		if object is Player:
			return SUCCESS
	return FAILURE

