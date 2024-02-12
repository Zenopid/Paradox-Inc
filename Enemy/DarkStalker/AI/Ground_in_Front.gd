extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.get_raycast("GroundChecker").force_raycast_update()
	if actor.get_raycast("GroundChecker").is_colliding(): 
		return SUCCESS
	return FAILURE

