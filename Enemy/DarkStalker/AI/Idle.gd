extends ActionLeaf

@export var decel_rate: float = 0.45
var los: RayCast2D

func before_run(actor: Node, blackboard: Blackboard) -> void:
	los = actor.get_raycast("LOS")
	actor.anim_player.play("Idle")

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if los.is_colliding():
		var object = los.get_collider()
		if object is Player:
			return FAILURE
	actor.motion.x *= decel_rate
	return RUNNING
