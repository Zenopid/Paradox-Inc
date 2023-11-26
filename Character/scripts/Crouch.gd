extends MoveState

var superjump_timer: Timer
@export var superjump_buffer: float = 0.15

func enter(_msg: = {}):
	super.enter()
	superjump_timer = state_machine.get_timer("Superjump")
	superjump_timer.wait_time = superjump_buffer

func physics_process(_delta):
	var was_on_floor = entity.is_on_floor()
	entity.motion.x *= 0.7
	get_movement_input()
	default_move_and_slide()
	
	if was_on_floor and !entity.is_on_floor() and coyote_timer.is_stopped():
		coyote_timer.start()
	if !entity.is_on_floor() and state_machine.get_timer("Coyote"):
		state_machine.transition_to("Fall")
		return

func input(_event):
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {can_superjump = true})
	if !Input.is_action_pressed("crouch"):
		if get_movement_input() != 0:
			state_machine.transition_to("Run")
			return
		else:
			state_machine.transition_to("Idle")
			return
	if Input.is_action_just_pressed("dodge") and state_machine.get_timer("Dodge_Cooldown").is_stopped():
		state_machine.transition_to("Dodge")
		return

func exit() -> void:
	state_machine.get_timer("Superjump").start()
