extends PlayerMoveState

var superjump_timer: Timer
var fall_scipt:Fall
@export var superjump_buffer: float = 0.15
@export var decelerate_value: float = 0.4

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	superjump_timer = state_machine.get_timer("Superjump")
	superjump_timer.wait_time = superjump_buffer
	fall_scipt = state_machine.find_state("Fall")
	jump_script = state_machine.find_state("Jump")
	
func enter(_msg:= {}):
	super.enter()
	entity.brace()

func physics_process(delta):
	entity = entity as Player
	var was_on_floor = grounded()
	entity.velocity.x *= decelerate_value
	entity.velocity.y = clamp(entity.velocity.y, entity.velocity.y + jump_script.get_gravity(), fall_scipt.maximum_fall_speed)
	entity.move_and_slide()
	if was_on_floor and !grounded() and coyote_timer.is_stopped():
		coyote_timer.start()
	state_machine.transition_if_available(["Fall"])

func input(event):
	super.input(event)
	if state_machine.transition_if_available(["Attack"]):
		return
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {can_superjump = true})
		return 
	if state_machine.transition_if_available(["Dodge"]):
		return
	if !Input.is_action_pressed("crouch"):
		state_machine.transition_if_available([
			"Run",
			"Idle"
		])

func exit() -> void:
	superjump_timer.start()
	entity.relax()
	
func conditions_met() -> bool:
	return Input.is_action_pressed("crouch") and grounded()
