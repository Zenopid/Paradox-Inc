extends PlayerBaseState


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

var wall_checker: RayCast2D

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	slope_checker_left = state_machine.get_raycast("SlopeCheckerRight")
	slope_checker_right = state_machine.get_raycast("SlopeCheckerLeft")
	ground_checker = state_machine.get_raycast("GroundChecker")
	wall_checker = state_machine.get_raycast("WallChecker")
	
	coyote_timer = state_machine.get_timer("Coyote")
	cooldown_timer = state_machine.get_timer("Slide_Cooldown")
	
	fall_state = state_machine.find_state("Fall")
	jump_node = state_machine.find_state("Jump")
	
	cooldown_timer.wait_time = slide_cooldown
	coyote_timer.wait_time = coyote_duration
	
func enter(_msg: = {}):
	super.enter()
	current_slide_duration = slide_duration
	if facing_left():
		slide_direction = -1
	else:
		slide_direction = 1
	hit_max_speed = false 
	wall_checker.enabled = true 
	
	
func speed_timer_logic(delta):
	if hit_max_speed and grounded():
		current_slide_duration -= delta

func physics_process(delta):
	
	speed_timer_logic(delta)
	wall_checker.position.x = entity.position.x + 12.55 * slide_direction
	wall_checker.position.y =  entity.position.y - 10.5 
	
	slope_checker_right.position = Vector2(entity.position.x + 1, entity.position.y + 13.5)
	slope_checker_left.position = Vector2(entity.position.x - 1, entity.position.y + 13.5)
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)
	if current_slide_duration <= 0:
		if is_on_slope() and !ascending_slope():
			pass
		else:
			if can_fall():
				return
			entity.motion.x = slow_down(entity.motion.x) 
	else:
		if abs(entity.motion.x) < slide_speed:
			entity.motion.x += slide_acceleration * sign(entity.motion.x)
			if abs(entity.motion.x) > slide_speed:
				entity.motion.x = slide_speed * sign(entity.motion.x)
#		entity.motion.x += slide_acceleration * slide_direction
#		entity.motion.x = clamp(entity.motion.x, -slide_speed, slide_speed)
	hit_max_speed = true if abs(entity.motion.x) >= abs(slide_speed) else false
	#if can_fall():
		#return
	if entity.motion.x  == 0:
		if can_fall():
			return
		if Input.is_action_pressed("crouch"):
			state_machine.transition_to("Crouch", {}, "Slide_to_Crouch")
			return
		enter_move_state()
		return
	if !grounded():
		entity.motion.y += gravity_acceleration
		if entity.motion.y > max_gravity:
			entity.motion.y = max_gravity
		if entity.is_on_wall():
			if wall_checker.is_colliding():
				state_machine.transition_to("WallSlide")
			else: 
				state_machine.transition_to("Fall")
			return
	if !is_on_slope():
		default_move_and_slide()
	else:
		move_and_slide_with_slopes(delta)
#	var test_num = randi_range(0,2)
#	if test_num == 1:
#		print(calculate_slope())
	push_objects()

func input(_event: InputEvent):
	if enter_attack_state():
		return
	if Input.is_action_just_pressed("jump"):
		jump_node.remaining_jumps += 1 
		#for some reason, you can't jump without this.
		state_machine.transition_to("Jump", {overwrite_speed = Vector2(-1, jump_velocity)})
		return
	if enter_dodge_state():
		return
	if !Input.is_action_pressed("crouch"):
		enter_move_state()

func slow_down(speed: float):
	speed = int(round(speed))
	speed = move_toward(speed, 0, slide_deceleration)
#	if facing_left():
#		speed += slide_deceleration
#		if speed > 0:
#			speed = 0
#	else:
#		speed -= slide_deceleration
#		if speed < 0:
#			speed = 0
	return speed

func exit() -> void:
	cooldown_timer.start()
#	hit_max_speed = false
#	current_slide_duration = slide_duration
#	ground_checker.enabled = false
	entity.sprite.rotation_degrees = 0
	entity.get_node("Hurtbox").rotation_degrees = 0
	wall_checker.enabled = false
	
func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is MoveableObject:
			collision.get_collider().apply_central_impulse(- collision.get_normal() * push)

func move_and_slide_with_slopes(delta):
	if state_machine.get_current_state().name != "Idle":
		entity.motion.y += jump_node.get_gravity() * delta
		entity.motion.y = clamp(entity.motion.y, 0, fall_state.maximum_fall_speed)
	entity.set_velocity(entity.motion)
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
	var point_a = ground_checker.get_collision_point()
	var point_b
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
