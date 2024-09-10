extends BaseState

@export var run_speed:int = 175
@export var chase_duration: float = 1.4
var ground_checker:RayCast2D 
var los_shapecast: ShapeCast2D
var chase_timer:Timer


func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity, s_machine)
	ground_checker = state_machine.get_raycast("GroundChecker")
	los_shapecast = state_machine.get_shapecast("LOS")
	chase_timer = state_machine.get_timer("ChaseDuration")
	chase_timer.wait_time = chase_duration

func enter(_msg: = {}):
	super.enter(_msg)
	los_shapecast.enabled = true
	ground_checker.enabled = true 
	chase_timer.start()

func physics_process(delta:float):
	los_shapecast.position = entity.position
	var offset_x = -10 if facing_left() else 10
	ground_checker.position = Vector2(entity.position.x + offset_x, entity.position.y)
	entity.velocity.x = run_speed if !facing_left() else -run_speed
	entity.move_and_slide()
	if chase_timer.is_stopped() or !ground_checker.is_colliding():
		state_machine.transition_if_available([
			"Shoot",
			"Dodge",
			"Active"
		])

func exit():
	los_shapecast.enabled = false
	ground_checker.enabled = false
