extends MoveState

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

func physics_process(_delta):
	var was_on_floor = grounded()
	entity.motion.x *= decelerate_value
	if entity.motion.y < fall_scipt.maximum_fall_speed:
		entity.motion.y += jump_script.get_gravity()
	get_movement_input()
	default_move_and_slide()
	
	if was_on_floor and !grounded() and coyote_timer.is_stopped():
		coyote_timer.start()
	if can_fall():
		return

func input(_event):
	if enter_attack_state():
		return
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {can_superjump = true})
		return 
	if !Input.is_action_pressed("crouch"):
		enter_move_state()
		return
	if enter_dodge_state():
		return

func exit() -> void:
	superjump_timer.start()
	entity.ease()
