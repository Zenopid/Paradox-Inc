extends ActionLeaf

@export var anim_name:String = "Run"
@export var movement_speed: int = 200
@export var accel_speed: int = 25
var facing: int = 0

func before_run(actor: Node, blackboard: Blackboard) -> void:
	actor.anim_player.play(anim_name)
	if actor.sprite.flip_h:
		facing = -1
		return
	facing = 1

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.motion.x += facing * accel_speed
	actor.motion.x = clamp(actor.motion.x, -movement_speed, movement_speed) 
	actor.default_move_and_slide()
	return SUCCESS

