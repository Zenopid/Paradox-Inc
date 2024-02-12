extends ActionLeaf

@export var anim_name: String = "Idle"
@export var decel_rate: float = 0.45

func before_run(actor: Node, blackboard: Blackboard) -> void:
	actor.anim_player.play(anim_name)

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.motion.x *= decel_rate
	return RUNNING
