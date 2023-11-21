class_name MoveState extends BaseState

@export var acceleration = 25
@export var move_speed = 125

@export var coyote_duration: float = 0.4

@export_range(1, 200) var push: int = 50

var coyote_timer: Timer

var push_counter: int = 0

func enter(_msg: = {}) -> void:
	super.enter()
	coyote_timer = state_machine.get_timer("Coyote")
	coyote_timer.wait_time = coyote_duration
	coyote_timer.one_shot = true

func input(event):
	if Input.is_action_just_pressed("dodge") and state_machine.get_timer("Dodge_Cooldown").is_stopped():
		state_machine.transition_to("Dodge")
		return
	if Input.is_action_just_pressed("jump"):
		if state_machine.get_timer("Superjump").is_stopped():
			state_machine.transition_to("Jump")
		else:
			state_machine.transition_to("Jump", {can_superjump = true})
		return
	if Input.is_action_pressed("crouch"):
		if state_machine.get_timer("Slide_Cooldown").is_stopped():
			if facing_left():
				if entity.motion.x <= -move_speed:
					state_machine.transition_to("Slide")
					return
			else:
				if entity.motion.x >= move_speed:
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

func physics_process(_delta:float) -> void:
	var was_on_floor = entity.is_on_floor()
	var move = get_movement_input()
	if move != 0:
		entity.motion.x += acceleration * move
		if !facing_left():
			if entity.motion.x > move_speed:
				entity.motion.x = move_speed  
		else:
			if entity.motion.x < -move_speed:
				entity.motion.x = -move_speed
	else:
		entity.motion.x *= 0.85
	move_and_slide_with_slopes()
	if was_on_floor and !entity.is_on_floor() and coyote_timer.is_stopped():
		coyote_timer.start()
	if !entity.is_on_floor() and state_machine.get_timer("Coyote").is_stopped():
		state_machine.transition_to("Fall")
		return
	if state_machine.get_current_state() == state_machine.find_state("Run"):
		push_objects()


func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is MoveableObject:
			print(-collision.get_normal() * push)
			collision.get_collider().lock_rotation = false
			collision.get_collider().apply_central_impulse( -collision.get_normal() * push )

func move_and_slide_with_slopes():
	entity.set_velocity(entity.motion)
	entity.set_up_direction(Vector2.UP)
	entity.set_floor_stop_on_slope_enabled(false)
	entity.set_max_slides(4)
	entity.set_floor_max_angle(PI/2)
	entity.move_and_slide()
	entity.motion = entity.velocity

func exit() -> void:
	state_machine.get_timer("Coyote").stop()
