extends ConditionLeaf

@export var attack_distance: int = 40

func tick(actor: Node, blackboard: Blackboard) -> int:
	var los: RayCast2D = actor.get_raycast("LOS")
	var point = los.get_collision_point()
	if abs(actor.global_position.x - point.x) <= attack_distance:
		return SUCCESS
	return FAILURE
