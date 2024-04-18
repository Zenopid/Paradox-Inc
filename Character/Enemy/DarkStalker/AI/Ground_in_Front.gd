extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var ground_checker:RayCast2D= actor.get_raycast("GroundChecker")
	if !ground_checker.is_colliding():
		return FAILURE
	return SUCCESS

