extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.has_method("is_in_hitstun"):
		if actor.is_in_hitstun():
			return SUCCESS
	return FAILURE
