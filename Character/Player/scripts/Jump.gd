class_name Jump extends PlayerAirState


@export var jump_squat_frames:int = 3
@export var double_jumps: int = 1
@export var jump_height : float = 400
@export var jump_time_to_peak: float = 0.7
@export var jump_time_to_descent: float = 0.8

@export_range(0, 1) var double_jump_strength: float = 0.75
@export var double_jump_boost: int = 50


@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var ground_checker:RayCast2D 
@onready var wall_checker: ShapeCast2D
@onready var coyote_timer:Timer

@export_range(1,2) var superjump_bonus: float = 1.25

@export var minimum_doublejump_speed: int = 100

var jump_squat_over: bool = false
var jump_squat_frames_tracker: int = 0
var jump_speed:Vector2
var speed_before_wallslide: float = 0

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	ground_checker = s_machine.get_raycast("GroundChecker")
	wall_checker = s_machine.get_shapecast("WallScanner")
	coyote_timer = s_machine.get_timer("Coyote")

func enter(msg: = {}):
	jump_squat_over = true
	jump_speed = Vector2(0, jump_velocity)
	var double_jump_multiplier: float = 1
	wall_checker.enabled = true
	for i in msg.keys():
		match i:
			"bonus_speed":
				jump_speed += Vector2(msg["bonus_speed"].x * get_facing_as_int(), msg["bonus_speed"].y)
			"can_superjump":
				jump_speed.y *= superjump_bonus
			"overwrite_speed":
				if msg["overwrite_speed"].x != -1:
					jump_speed.x = msg["overwrite_speed"].x
				if msg["overwrite_speed"].y != -1:
					jump_speed.y = msg["overwrite_speed"].y
			"double_jump_multiplier":
				double_jump_multiplier = msg["double_jump_multiplier"]
	if grounded() or !coyote_timer.is_stopped():
		apply_jump_squat()
	else:
		var boost: Vector2 = Vector2.ZERO
		if msg.has("double_jump_bonus_speed"):
			boost = msg["double_jump_bonus_speed"]
		double_jump(double_jump_multiplier, boost)
		super.enter()

	

func physics_process(delta):
	if jump_squat_over:
		ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)
		super.physics_process(delta)
		entity.velocity.y += get_gravity() 
		if entity.velocity.y >= 0:
			state_machine.transition_to("Fall")
			return
		wall_checker.position = Vector2( entity.position.x + 12.55 * get_facing_as_int(), entity.position.y - 10.5)
		if wall_checker.is_colliding() and !ground_checker.is_colliding() and !Input.is_action_pressed("jump") and get_movement_input() != 0:
			state_machine.transition_to("WallSlide", {previous_speed = speed_before_wallslide})
			return
		elif !wall_checker.is_colliding():
			speed_before_wallslide = entity.velocity.x
	#else:
		#jump_squat_frames_tracker += 1
		#if jump_squat_frames_tracker >= jump_squat_frames:
			#leave_jump_squat()
	default_move_and_slide()

func apply_jump_squat():
	entity.velocity.x += jump_speed.x
	jump_squat_over = false 
	entity.anim_player.play("Jump Squat")
	await entity.anim_player.animation_finished
	jump_squat_over = true
	entity.anim_player.play("Jump")
	entity.velocity.y += jump_speed.y

	

func input(_event:InputEvent):
	
	super.input(_event)
	if enter_dodge_state():
		return
	if enter_attack_state():
		return
	if Input.is_action_just_pressed("jump") and entity.velocity.y > -minimum_doublejump_speed and remaining_jumps > 0 and jump_squat_over:
		double_jump()

func double_jump(additional_multiplier: float = 1, boost: Vector2 = Vector2.ZERO):
	entity.velocity.y = (jump_velocity * double_jump_strength) * additional_multiplier
	if abs(entity.velocity.x) < entity.max_grapple_speed:
		entity.velocity.x += double_jump_boost * get_movement_input()
		entity.velocity.x = clamp(entity.velocity.x, -entity.max_grapple_speed, entity.max_grapple_speed)
	entity.velocity += boost
	remaining_jumps -= 1

func get_gravity() -> float:
	var gravity = jump_gravity if entity.velocity.y < 0.0 else fall_gravity
	return gravity * get_physics_process_delta_time()

func get_jump_gravity() -> float:
	return jump_gravity

func get_fall_gravity() -> float:
	return fall_gravity
	
func add_jump(jump_cnt: int = 1):
	remaining_jumps += jump_cnt

func get_jumps() -> int:
	return remaining_jumps

func exit() -> void:
	if grounded():
		remaining_jumps = double_jumps
	wall_checker.enabled = false
