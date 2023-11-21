class_name Fall extends AirState

var jump_node: Jump

@export var maximum_fall_speed: int = 400

var jump_buffer: Timer

@export var buffer_duration: float = 0.6

var wall_checker: RayCast2D 
var ground_checker: RayCast2D


func enter(_msg: = {}) -> void:
	wall_checker = state_machine.get_raycast("WallChecker")
	ground_checker = state_machine.get_raycast("GroundChecker")
	super.enter()
	jump_node = state_machine.find_state("Jump")
	jump_buffer = state_machine.get_timer("Jump_Buffer")
	jump_buffer.wait_time = buffer_duration
	wall_checker.enabled = true
	ground_checker.enabled = true
func input(_event: InputEvent):
	if Input.is_action_just_pressed("jump"):
		if jump_node.remaining_jumps > 0: 
			state_machine.transition_to("Jump")
			return
		else:
			jump_buffer.start()

func physics_process(delta):
	super.physics_process(delta)
	
	entity.motion.y += jump_node.get_gravity() * delta
	if entity.motion.y > maximum_fall_speed:
		entity.motion.y = maximum_fall_speed
	if entity.is_on_floor():
		if !jump_buffer.is_stopped():
			state_machine.transition_to("Jump")
			jump_buffer.stop()
			return
		if Input.is_action_pressed("crouch"):
			if state_machine.get_timer("Slide_Cooldown").is_stopped() and get_movement_input() != 0:
				if entity.motion.x <= -max_speed:
					state_machine.transition_to("Slide")
					return
				elif entity.motion.x >= max_speed:
					state_machine.transition_to("Slide")
					return
			state_machine.transition_to("Crouch")
			return
		if get_movement_input() != 0:
			state_machine.transition_to("Run")
			return
		else:
			state_machine.transition_to("Idle")
			return
	set_raycast_positions()
	if wall_checker.is_colliding() and !ground_checker.is_colliding() and get_movement_input() != 0:
		state_machine.transition_to("WallSlide")
		return
	default_move_and_slide()
	
func set_raycast_positions():
	if facing_left():
		wall_checker.position.x = entity.position.x - 12.55
	else:
		wall_checker.position.x = entity.position.x + 12.55
	wall_checker.position.y =  entity.position.y -10.5 
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)

func exit() -> void:
	if entity.is_on_floor():
		jump_node.remaining_jumps = jump_node.double_jumps
	wall_checker.enabled = false
	ground_checker.enabled = false
