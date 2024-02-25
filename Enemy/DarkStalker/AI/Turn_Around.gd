extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.sprite.flip_h = !actor.sprite.flip_h
	actor.hitsparks.scale.x *= -1
	return SUCCESS
