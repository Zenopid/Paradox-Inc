extends ConditionLeaf

@export var acceptable_distance: Vector2 = Vector2(150,25)

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.player_near():
		return SUCCESS
	return FAILURE
