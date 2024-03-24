extends ActionLeaf

@export_enum("Left", "Right")var direction: String = "Right"
@export var dash_speed: int = 75
@export var lock_ray_direction: bool = true

var ground_checker:RayCast2D
var los_raycast: RayCast2D
var facing: int = 1
var current_los_scale_x

func before_run(actor: Node, blackboard: Blackboard) -> void:
	ground_checker = actor.get_raycast("GroundChecker")
	los_raycast = actor.get_raycast("LOS")
	los_raycast.lock_view()
	ground_checker.lock_position()
	current_los_scale_x = los_raycast.scale.x
	if direction == "Left":
		facing = -1
	elif direction == "Right":
		facing = 1
	if !lock_ray_direction:
		los_raycast.scale.x = facing
	actor.anim_player.play("Run")
	
func tick(actor: Node, _blackboard: Blackboard) -> int:
	ground_checker.position.x = actor.position.x + (14 * facing)
	if !ground_checker.is_colliding():
		return FAILURE
	actor.motion.x = dash_speed * facing
	actor.default_move_and_slide()
	return SUCCESS

func after_run(actor: Node, blackboard: Blackboard) -> void:
	if !lock_ray_direction:
		los_raycast.scale.x = current_los_scale_x
	los_raycast.unlock_view()
	ground_checker.unlock_position()
