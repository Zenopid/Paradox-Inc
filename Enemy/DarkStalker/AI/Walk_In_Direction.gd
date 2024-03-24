extends ActionLeaf

@export var anim_name:String = "Run"
@export var movement_speed: int = 200
@export var accel_speed: int = 25
var facing: int = 0

var ground_checker: RayCast2D
var los:RayCast2D

func before_run(actor: Node, blackboard: Blackboard) -> void:
	los = actor.get_raycast("LOS")
	actor.anim_player.play(anim_name)
	ground_checker = actor.get_raycast("GroundChecker")
	if actor.sprite.flip_h:
		facing = -1
		return
	facing = 1

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if los.is_colliding():
		var object = los.get_collider()
		if object is Player:
			return FAILURE
	if !ground_checker.is_colliding():
		actor.motion.x *= -1
		actor.sprite.flip_h = !actor.sprite.flip_h
		return FAILURE
	actor.motion.x += facing * accel_speed
	actor.motion.x = clamp(actor.motion.x, -movement_speed, movement_speed) 
	actor.default_move_and_slide()
	return SUCCESS

