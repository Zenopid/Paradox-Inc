class_name Jump extends AirState


@export var double_jumps: int = 1
@export var jump_height : float = 400
@export var jump_time_to_peak: float = 0.7
@export var jump_time_to_descent: float = 0.8

@export_range(0, 1) var double_jump_strength: float = 0.75
@export var double_jump_boost: int = 50


@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@export_range(0,1) var superjump_bonus: float = 0.25

func enter(msg: = {}):
	super.enter()
	var jump_speed: Vector2 = Vector2(0, jump_velocity)
	if msg.has("bonus_speed"):
		jump_speed.x += msg["bonus_speed"].x
		jump_speed.y += msg["bonus_speed"].y
	if msg.has("can_superjump"):
		if msg["can_superjump"] == true:
			jump_speed.y *= 1 + superjump_bonus
	if entity.is_on_floor() or !state_machine.get_timer("Coyote").is_stopped():
		entity.motion.y = jump_speed.y
		entity.motion.x += jump_speed.x 
	else:
		double_jump()
	

func physics_process(delta):
	super.physics_process(delta)
	entity.motion.y += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and entity.motion.y > -100 and remaining_jumps > 0:
		double_jump()
	if entity.motion.y > 0:
		state_machine.transition_to("Fall")
		return
	default_move_and_slide()

func double_jump():
	entity.motion.y = jump_velocity * double_jump_strength
	var boost = double_jump_boost * get_movement_input()
	if facing_left():
		if entity.motion.x > -max_speed:
			if entity.motion.x + boost < -max_speed:
				entity.motion.x += boost
				if entity.motion.x < -max_speed:
					entity.motion.x = -max_speed
	else:
		if entity.motion.x < max_speed:
			if entity.motion.x + boost > max_speed:
				entity.motion.x += boost
				if entity.motion.x > max_speed:
					entity.motion.x = max_speed
	remaining_jumps -= 1
	super.enter()

func get_gravity() -> float:
	return jump_gravity if entity.motion.y < 0.0 else fall_gravity

func exit() -> void:
	if entity.is_on_floor():
		remaining_jumps = double_jumps
