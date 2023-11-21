extends BaseState

@export var slide_acceleration:int = 5
@export var slide_deceleration: int = 5
@export var slide_speed:int = 325 
@export var slide_duration: float = 0.6
@export var slide_cooldown: float = 0.7

@export var coyote_duration: float = 0.15

@export_range(1, 500) var push: int = 50


var duration_timer: Timer
var cooldown_timer: Timer

var jump_node:Jump

var hit_max_speed: bool

var current_slide_duration: float = 0

var slide_direction:int 

var func_passes:int = 0

var coyote_timer: Timer 

func enter(_msg: = {}):
	super.enter()
	coyote_timer = state_machine.get_timer("Coyote")
	coyote_timer.wait_time = coyote_duration
	cooldown_timer = state_machine.get_timer("Slide_Cooldown")
	cooldown_timer.wait_time = slide_cooldown
	jump_node = state_machine.find_state("Jump")
	current_slide_duration = slide_duration
	if facing_left():
		slide_direction = -1
	else:
		slide_direction = 1
	current_slide_duration = slide_duration

func process(delta):
	if hit_max_speed:
		current_slide_duration -= delta
		if current_slide_duration < 0:
			current_slide_duration = 0

func physics_process(_delta):
	var was_on_floor = entity.is_on_floor()
	if current_slide_duration <= 0:
		entity.motion.x = slow_down(entity.motion.x) 
	else:
		entity.motion.x += slide_acceleration * slide_direction
		if facing_left():
			if entity.motion.x < -slide_speed:
				entity.motion.x = -slide_speed
				hit_max_speed = true
		else:
			if entity.motion.x > slide_speed:
				entity.motion.x = slide_speed
				hit_max_speed = true
	if was_on_floor and entity.is_on_floor() and coyote_timer.is_stopped():
		coyote_timer.start()
	if !entity.is_on_floor() and coyote_timer.is_stopped():
		state_machine.transition_to("Fall")
		return
	if entity.motion.x  == 0:
		if Input.is_action_pressed("crouch"):
			state_machine.transition_to("Crouch", {}, "Slide_to_Crouch")
			return
		else:
			if get_movement_input() != 0:
				state_machine.transition_to("Run")
				return
			else:
				state_machine.transition_to("Idle")
				return
	default_move_and_slide()
	push_objects()

func input(_event: InputEvent):
	if !Input.is_action_pressed("crouch"):
		if get_movement_input() != 0:
			state_machine.transition_to("Run")
			return
		else:
			state_machine.transition_to("Idle")
			return
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {bonus_speed = Vector2(0, (-1.0 * jump_node.jump_velocity))})
		return
	if Input.is_action_just_pressed("dodge"):
		state_machine.transition_to("Dodge")
		return

func slow_down(speed):
	if facing_left():
		speed += slide_deceleration
		if speed > 0:
			speed = 0
	else:
		speed -= slide_deceleration
		if speed < 0:
			speed = 0
	return speed

func exit() -> void:
	cooldown_timer.start()
	hit_max_speed = false
	current_slide_duration = slide_duration

func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is MoveableObject:
			collision.get_collider().apply_central_impulse(- collision.get_normal() * push)
