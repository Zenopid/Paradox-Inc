extends BaseState

@onready var shoot_cooldown:Timer
@onready var target_position:Vector2
@onready var los_raycast: RayCast2D
func init(current_entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	shoot_cooldown = state_machine.get_timer("Shoot_Cooldown")
	los_raycast = state_machine.get_raycast("LOS")
func enter(msg: = {}):
	super.enter()
	print_debug(entity.name + " entered shoot state, but we don't have code for that yet, so going to idle")
	los_raycast.target_position = msg["target_position"]
	state_machine.transition_to("Idle")
