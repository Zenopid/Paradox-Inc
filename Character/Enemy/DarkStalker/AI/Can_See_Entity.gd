extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var los: RayCast2D = actor.get_raycast("LOS")
	if los.is_colliding():
		var object = los.get_collider()
		if object is Player:
			blackboard.set_value("target_position", object.global_position)
			return SUCCESS
	return FAILURE
