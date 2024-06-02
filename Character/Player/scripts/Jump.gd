class_name Jump extends PlayerAirState

const SUPERJUMP_PITCH_SCALE: float = 1.25
const FASTFALL_MULTIPLIER: float = 2.5

@export var bunny_hop_bonus: float = 1.05

@export var jump_squat_frames:int = 3
@export var double_jumps: int = 1
@export var jump_height : float = 400
@export var jump_time_to_peak: float = 0.7
@export var jump_time_to_descent: float = 0.8
@export var fastfall_cooldown:float = 0.1
@export_range(0, 1) var double_jump_strength: float = 0.75
@export var double_jump_boost: int = 50


@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var ground_checker:RayCast2D 
@onready var wall_checker: ShapeCast2D
@onready var coyote_timer:Timer
@onready var fastfall_timer:Timer

@onready var sfx:AudioStreamPlayer = $Sfx

@onready var right_particles:GPUParticles2D = $"%ParticlesRight"
@onready var left_particles:GPUParticles2D = $"%ParticlesLeft"
@onready var superjump_particles:GPUParticles2D = $"%SuperJump"

@export_range(1,2) var superjump_bonus: float = 1.25

@export var minimum_doublejump_speed: int = 100

var jump_squat_over: bool = false
var jump_squat_frames_tracker: int = 0
var jump_speed:Vector2
var speed_before_wallslide: float = 0
var superjumping:bool = false
var jump_buffer:Timer
var superjump_timer:Timer

var already_jumped:bool = false

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	ground_checker = s_machine.get_raycast("GroundChecker")
	wall_checker = s_machine.get_shapecast("WallScanner")
	coyote_timer = s_machine.get_timer("Coyote")
	jump_buffer = state_machine.get_timer("Jump_Buffer")
	fastfall_timer = state_machine.get_timer("Fastfall_Lockout")
	fastfall_timer.wait_time = fastfall_cooldown
	superjump_timer = s_machine.get_timer("Superjump")
	
func enter(msg: = {}):
	already_jumped = true 
	if !jump_buffer.is_stopped():
		entity.velocity.x *= bunny_hop_bonus
	jump_buffer.stop()
	fastfall_timer.start()
	superjumping = !superjump_timer.is_stopped()
	jump_squat_over = true
	jump_speed = Vector2(0, jump_velocity)
	var double_jump_multiplier: float = 1
	wall_checker.enabled = true
	sfx.pitch_scale = 1
	if superjumping:
		jump_speed.y *= superjump_bonus
		sfx.pitch_scale = SUPERJUMP_PITCH_SCALE
	for i in msg.keys():
		match i:
			"bonus_speed":
				jump_speed += Vector2(msg["bonus_speed"].x * get_facing_as_int(), msg["bonus_speed"].y)
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
	entity = entity as Player
	superjump_particles.position = Vector2(entity.position.x, entity.position.y + 35)
	if jump_squat_over:
		ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)
		super.physics_process(delta)
		entity.velocity.y += get_gravity() 
		if entity.velocity.y >= 0:
			state_machine.transition_to("Fall")
			return
		wall_checker.position = Vector2( entity.position.x + 12.55 * get_facing_as_int(), entity.position.y - 10.5)
		if state_machine.state_available("WallSlide"):
			state_machine.transition_to("WallSlide", {previous_speed = speed_before_wallslide})
			return
		elif !wall_checker.is_colliding():
			speed_before_wallslide = entity.velocity.x
	default_move_and_slide()

func apply_jump_squat():
	entity.velocity.x += jump_speed.x
	jump_squat_over = false 
	entity.anim_player.play("Jump Squat")
	await entity.anim_player.animation_finished
	jump_squat_over = true
	entity.anim_player.play("Jump")
	jump_speed.y = clampf(jump_speed.y, jump_velocity * superjump_bonus, 0 )
	entity.velocity.y += jump_speed.y
	print("Normal jumpin")



func input(event:InputEvent):
	
	super.input(event)
	if state_machine.transition_if_available([
		"Dodge",
		"Attack",
	]):
		return
	if Input.is_action_just_pressed("jump") and entity.velocity.y > -minimum_doublejump_speed and remaining_jumps > 0 and jump_squat_over:
		double_jump()

func double_jump(additional_multiplier: float = 1, boost: Vector2 = Vector2.ZERO):
	if remaining_jumps <= 0:
		remaining_jumps = 0
		return
	entity.velocity.y = (jump_velocity * double_jump_strength) * additional_multiplier
	if abs(entity.velocity.x) < entity.max_grapple_speed:
		entity.velocity.x += double_jump_boost * get_movement_input()
		entity.velocity.x = clamp(entity.velocity.x, -entity.max_grapple_speed, entity.max_grapple_speed)
	entity.velocity += boost
	print(remaining_jumps)
	remaining_jumps -= 1

func get_gravity(print_gravity:bool = false) -> float:
	var gravity:float
	var print_statement:String
	if entity.velocity.y < 0.0:
		print_statement = "Jump"
		gravity = jump_gravity
	else:
		print_statement = "Fall"
		gravity = fall_gravity
	if print_gravity:
		print(print_statement)
	if Input.is_action_pressed("crouch") and fastfall_timer.is_stopped():
		if entity.velocity.y < 0:
			entity.velocity.y = 0
		gravity *= FASTFALL_MULTIPLIER
	return gravity * get_physics_process_delta_time()

func get_jump_gravity() -> float:
	return jump_gravity

func get_fall_gravity() -> float:
	return fall_gravity
	
func add_jump(jump_cnt: int = 1, remove_limiter:bool = false):
	remaining_jumps += jump_cnt
	if !remove_limiter:
		remaining_jumps = clampi(remaining_jumps, 1, double_jumps)

func get_jumps() -> int:
	return remaining_jumps

func exit() -> void:
	if grounded():
		remaining_jumps = double_jumps
	wall_checker.enabled = false

func conditions_met() -> bool:
	if !jump_buffer.is_stopped() or Input.is_action_just_pressed("jump"):
		if grounded() and !already_jumped:
			return true
		elif !grounded() and remaining_jumps > 0 and entity.velocity.y > -minimum_doublejump_speed:
			return true
	return false
func inactive_process(delta:float) -> void:
	if grounded():
		already_jumped = false 

func emit_particles() -> void: 
	if superjumping:
		superjump_particles.process_material.angle_min = 5 * get_movement_input()
		superjump_particles.process_material.angle_max = superjump_particles.process_material.angle_min
		if !superjump_particles.emitting:
			superjump_particles.emitting = true
		else:
			superjump_particles.restart()
	left_particles.position = Vector2(entity.position.x, entity.position.y + 18)
	right_particles.position = left_particles.position
	left_particles.scale.x = -1
	right_particles.scale.x = 1
	if grounded():
		if !left_particles.emitting:
			left_particles.emitting = true
		else:
			left_particles.restart()
		if !right_particles.emitting:
			right_particles.emitting = true
		else:
			right_particles.restart()
