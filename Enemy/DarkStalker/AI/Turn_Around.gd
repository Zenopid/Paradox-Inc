extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.sprite.flip_h = !actor.sprite.flip_h
	return SUCCESS
