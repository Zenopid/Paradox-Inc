extends ActionLeaf

@export_enum("LOS", "GroundChecker") var affected_ray: String
@export var lock_position: bool = false

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var active_ray: RayCast2D = actor.get_raycast(affected_ray)
	if !active_ray:
		print_debug("Something went wrong with flipping the ray " + str(active_ray) + "'s position.")
		return FAILURE
	active_ray.position.x *= -1
	if lock_position and active_ray.has_method("lock_position"):
		active_ray.lock_position()
	return SUCCESS
