class_name Jump extends AirState


@export var double_jumps: int = 1
@export var jump_height : float = 400
@export var jump_time_to_peak: float = 0.7
@export var jump_time_to_descent: float = 0.8
@export var jump_speed_decrease_on_released_button: float = 0.6

@export_range(0, 1) var double_jump_strength: float = 0.75
@export var double_jump_boost: int = 50


@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@export_range(1,2) var superjump_bonus: float = 1.25

@export var minimum_doublejump_speed: int = 100

var superjumping: bool = false
var released_jump_button: bool = false
var ground_checker:RayCast2D 

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	ground_checker = s_machine.get_raycast("GroundChecker")

func enter(msg: = {}):
	released_jump_button = false
	superjumping = false
	super.enter()
	var jump_speed: Vector2 = Vector2(0, jump_velocity)
	var double_jump_multiplier: float = 1
	var facing = -1 if facing_left() else 1
	for i in msg.keys():
		match i:
			"bonus_speed":
				jump_speed += Vector2(msg["bonus_speed"].x * facing, msg["bonus_speed"].y)
				#print("bonus speed is (" + str(msg["bonus_speed"].x) + "," + str(msg["bonus_speed"].y) + ")")
			"can_superjump":
				jump_speed.y *= superjump_bonus
				superjumping = true
				#print_debug("Superjumping!")
			"overwrite_speed":
				if msg["overwrite_speed"].x != -1:
					jump_speed.x = msg["overwrite_speed"].x
				if msg["overwrite_speed"].y != -1:
					jump_speed.y = msg["overwrite_speed"].y
			"double_jump_multiplier":
				double_jump_multiplier = msg["double_jump_multiplier"]
	if grounded() or !state_machine.get_timer("Coyote").is_stopped():
		entity.motion.y = jump_speed.y
		entity.motion.x += jump_speed.x 
	else:
		var boost: Vector2 = Vector2.ZERO
		if msg.has("double_jump_bonus_speed"):
			boost = msg["double_jump_bonus_speed"]
			#print("adding boost of " + str(boost) )
		double_jump(double_jump_multiplier, boost)
	if state_machine.previous_state.name == "Slide":
		print("from slide")
		print("velocity:" + str(entity.motion))

func physics_process(delta):
	if enter_dodge_state():
		return
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)
	super.physics_process(delta)
	entity.motion.y += get_gravity() * delta
	if entity.motion.y >= 0:
		state_machine.transition_to("Fall")
		return
	default_move_and_slide()

func input(_event:InputEvent):
	super.input(_event)
	if Input.is_action_just_pressed("jump") and entity.motion.y > -minimum_doublejump_speed and remaining_jumps > 0:
		double_jump()
#	if Input.is_action_just_released("jump"):
#		if !released_jump_button:
#			entity.motion.y *= 1 - jump_speed_decrease_on_released_button
#			released_jump_button = true 

func double_jump(additional_multiplier: float = 1, boost: Vector2 = Vector2.ZERO):
	entity.motion.y = (jump_velocity * double_jump_strength) * additional_multiplier
	var facing = -1 if get_movement_input() < 0 else 1
	if abs(entity.motion.x) < max_speed:
		entity.motion.x += double_jump_boost * get_movement_input()
		if abs(entity.motion.x) > max_speed:
			entity.motion.x = (double_jump_boost * facing) 
#	entity.motion.x += double_jump_boost * get_movement_input()
	entity.motion += boost
	remaining_jumps -= 1

func get_gravity() -> float:
	return jump_gravity if entity.motion.y < 0.0 else fall_gravity

func get_jump_gravity() -> float:
	return jump_gravity

func get_fall_gravity() -> float:
	return fall_gravity

func exit() -> void:
	if grounded():
		remaining_jumps = double_jumps
