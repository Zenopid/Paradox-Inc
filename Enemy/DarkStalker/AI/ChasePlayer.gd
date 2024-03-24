extends ActionLeaf

@export var escape_speed: int = 125
@export var acceleration_speed: int = 25

@export var distance_to_run_away: int = 25
var player_position: Vector2
var ground_checker:RayCast2D
var los_raycast: RayCast2D
var direction: int

func before_run(actor: Node, blackboard: Blackboard) -> void:
	player_position = blackboard.get_value("target_position")
	ground_checker = actor.get_raycast("GroundChecker")
	los_raycast = actor.get_raycast("LOS")
	direction = 1 if player_position.x < actor.position.x else -1
	los_raycast.lock_view()
	if !actor.sprite.flip_h:
		if direction < 0:
			actor.anim_player.play_backwards("Run")
		else:
			actor.anim_player.play("Run")
	else:
		if direction < 0:
			actor.anim_player.play_backwards("Run")
		else:
			actor.anim_player.play("Run")
		
		
func tick(actor: Node, _blackboard: Blackboard) -> int:
#	print_debug(player_position.x - actor.global_position.x)
	if abs(player_position.x - actor.global_position.x) >= distance_to_run_away:
		return SUCCESS
	ground_checker.force_raycast_update()
	if !ground_checker.is_colliding(): 
		return FAILURE
	actor.motion.x += direction * acceleration_speed
	actor.motion.x = clamp(actor.motion.x, -escape_speed, escape_speed) 
	actor.default_move_and_slide()
	return RUNNING

func after_run(actor: Node, blackboard: Blackboard) -> void:
	los_raycast.unlock_view()
