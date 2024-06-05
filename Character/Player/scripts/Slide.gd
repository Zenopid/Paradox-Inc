extends PlayerBaseState


@export var speed_to_slide:int = 250
@export var slide_acceleration:int = 5
@export var slide_deceleration: int = 5
@export var slide_speed:int = 325 
@export var slide_duration: float = 0.6
@export var slide_cooldown: float = 0.7
@export var coyote_duration: float = 0.15
@export var jump_height : float = 400
@export var jump_time_to_peak: float = 0.7
@export var gravity_acceleration: int = 20
@export var max_gravity:int = 200
@export_range(1, 500) var push: int = 50

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var particles:GPUParticles2D = $"%Particles"
var duration_timer: Timer
var cooldown_timer: Timer

var jump_node:Jump

var hit_max_speed: bool

var current_slide_duration: float = 0

var slide_direction:int 

var func_passes:int = 0

var coyote_timer: Timer 

var ground_checker:RayCast2D

var position_tracker:int 

var slope_checker_left:RayCast2D
var slope_checker_right: RayCast2D
var fall_state: Fall

var wall_checker: ShapeCast2D

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	slope_checker_left = state_machine.get_raycast("SlopeCheckerRight")
	slope_checker_right = state_machine.get_raycast("SlopeCheckerLeft")
	ground_checker = state_machine.get_raycast("GroundChecker")
	wall_checker = state_machine.get_shapecast("WallScanner")
	
	coyote_timer = state_machine.get_timer("Coyote")
	cooldown_timer = state_machine.get_timer("Slide_Cooldown")
	
	fall_state = state_machine.find_state("Fall")
	jump_node = state_machine.find_state("Jump")
	
	cooldown_timer.wait_time = slide_cooldown
	coyote_timer.wait_time = coyote_duration
	
func enter(_msg: = {}):
	super.enter()
	current_slide_duration = slide_duration
	slide_direction = get_facing_as_int()
	hit_max_speed = false 
	wall_checker.enabled = true 
	
	
func speed_timer_logic(delta):
	if hit_max_speed and grounded():
		current_slide_duration -= delta

func physics_process(delta):
	var is_grounded = grounded()
	particles.emitting = is_grounded
	particles.position = Vector2(entity.position.x, entity.position.y + 18)
	
	
	speed_timer_logic(delta)
	wall_checker.position = Vector2(entity.position.x + 12.55 * slide_direction, entity.position.y - 10.5)
	
	slope_checker_right.position = Vector2(entity.position.x + 1, entity.position.y + 13.5)
	slope_checker_left.position = Vector2(entity.position.x - 1, entity.position.y + 13.5)
	
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)
	if current_slide_duration <= 0:
		if is_on_slope() and !ascending_slope():
			pass
		else:
			if !is_grounded:
				return
			entity.velocity.x = slow_down(entity.velocity.x) 
	else:
		if abs(entity.velocity.x) < slide_speed:
			entity.velocity.x += slide_acceleration * get_movement_input()
			if abs(entity.velocity.x) > slide_speed:
				entity.velocity.x = slide_speed * sign(entity.velocity.x)
	hit_max_speed = true if abs(entity.velocity.x) >= abs(slide_speed) else false
	
	if entity.velocity.x  == 0:
		particles.emitting = false
		if Input.is_action_pressed("crouch") and is_grounded:
			state_machine.transition_to("Crouch", {}, "Slide_to_Crouch")
			return
		state_machine.transition_if_available([
		"Attack",
		"Jump",
		"Run",
		"Idle",
		])
	if !is_grounded:
		entity.velocity.y = clampi(entity.velocity.y, entity.velocity.y + gravity_acceleration, max_gravity)
		if state_machine.transition_if_available(["WallSlide"]):
			return
	else:
		emit_particles()
	if !is_on_slope():
		entity.move_and_slide()
	else:
		move_and_slide_with_slopes(delta)
	push_objects()


func input(event: InputEvent):
	super.input(event)
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {overwrite_speed = Vector2(-1, jump_velocity)})
		return
	if state_machine.transition_if_available([
		"Dodge",
		"Attack"
		]):
		return
	if !Input.is_action_pressed("crouch"):
		state_machine.transition_if_available([
			"Run",
			"Idle",
		])

func slow_down(speed: float) -> float:
	return move_toward(speed, 0, slide_deceleration)

func exit() -> void:
	cooldown_timer.start()
	wall_checker.enabled = false
	particles.emitting = false

func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			collision.get_collider().apply_central_impulse(- collision.get_normal() * push)

func move_and_slide_with_slopes(delta):
	if state_machine.get_current_state().name != "Idle":
		entity.velocity.y += jump_node.get_gravity() 
		entity.velocity.y = clamp(entity.velocity.y, 0, fall_state.maximum_fall_speed)
	entity.set_velocity(entity.velocity)
	entity.set_floor_stop_on_slope_enabled(true)
	entity.set_max_slides(1)
	entity.set_floor_max_angle(PI/2)
	entity.floor_snap_length = 2
	if ground_checker.get_collision_normal() != Vector2.ZERO:
		entity.set_up_direction(ground_checker.get_collision_normal())
	
	for i in range(2):
		entity.move_and_slide()
		entity.apply_floor_snap()
	
func calculate_slope():
	var point_a:Vector2 = ground_checker.get_collision_point()
	var point_b:Vector2
	if slope_checker_right.is_colliding():
		point_b = slope_checker_right.get_collision_point()
	else:
		point_b = slope_checker_left.get_collision_point()
	var opposite = abs(point_a.y - entity.position.y)
	var adjacent = max(point_b.x, entity.position.x) - min(point_b.x, entity.position.x)
	print(str(opposite)+ " is the opposite.")
	print(str(adjacent) + " is the adjacent.")
	return rad_to_deg(atan(adjacent/opposite))

func is_on_slope():
	slope_checker_left.force_raycast_update()
	slope_checker_right.force_raycast_update()
	if slope_checker_left.is_colliding() or slope_checker_right.is_colliding():
		return true
	return false

func ascending_slope():
	var facing = "left" if slide_direction < 0 else "right"
	if get("slope_checker_" + facing).is_colliding():
		return true
	return false

func conditions_met() -> bool:
	var move = get_movement_input()
	if cooldown_timer.is_stopped() and move != 0 and grounded():
		if abs(entity.velocity.x) >= speed_to_slide and Input.is_action_pressed("crouch"):
			if sign(entity.velocity.x) == sign(move):
				return true
	return false

func emit_particles() -> void:
	particles.scale.x = get_facing_as_int()
	particles.speed_scale = lerp(0.5, float(1.0), entity.velocity / entity.max_grapple_speed)
	if !particles.emitting:
		particles.emitting = true 
