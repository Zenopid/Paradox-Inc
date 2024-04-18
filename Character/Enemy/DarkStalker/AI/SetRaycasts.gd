extends ActionLeaf

@export var los_range: int = 250

func tick(actor: Node, blackboard: Blackboard) -> int:
	var LOS:RayCast2D = actor.get_raycast("LOS")
	var ground_ray: RayCast2D = actor.get_raycast("GroundChecker")
	var facing = 1 if !actor.sprite.flip_h else -1
	ground_ray.position = Vector2(actor.position.x + (14 * facing), actor.position.y + 10)
	LOS.position = Vector2(actor.position.x + (13 * facing), actor.position.y + 10)
	LOS.target_position.x = los_range * facing
	return SUCCESS
