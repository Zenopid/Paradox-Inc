class_name PlayerMoveState extends PlayerBaseState

signal turned_around()

const STICK_TO_GROUND: int = 140

@export var acceleration = 25
@export var move_speed = 125

@export var coyote_duration: float = 0.4

@export_range(1, 200) var push: int = 50

var coyote_timer: Timer

var push_counter: int = 0
var ground_checker: RayCast2D

@onready var slope_ray_right: RayCast2D
@onready var slope_ray_left: RayCast2D

var DECEL_VALUE: float = 0.6

var test_num: int = 0

var jump_script : PlayerBaseState
var fall_script : PlayerBaseState
var run_state : PlayerBaseState

func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	ground_checker = state_machine.get_raycast("GroundChecker")
	slope_ray_left = state_machine.get_raycast("SlopeCheckerLeft")
	slope_ray_right = state_machine.get_raycast("SlopeCheckerRight")
	coyote_timer = state_machine.get_timer("Coyote")
	coyote_timer.wait_time = coyote_duration
	coyote_timer.one_shot = true
	
	jump_script = state_machine.find_state("Jump")
	fall_script = state_machine.find_state("Fall")
	run_state = state_machine.find_state("Run")
	
func enter(_msg: = {}):
	super.enter()
	slope_ray_left.enabled = true
	slope_ray_right.enabled = true

func input(event):
	super.input(event)
	state_machine.transition_if_available([
		"Attack",
		"Dodge",
		"Jump",
		"Slide",
		"Crouch",
		"Run", 
		"Idle"
	])
	

func physics_process(delta:float) -> void:
	super.physics_process(delta)
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)
	slope_ray_left.position = Vector2(entity.position.x - 1, entity.position.y + 13.5)
	slope_ray_right.position = Vector2(entity.position.x + 1, entity.position.y + 13.5)
	var slope_checker:RayCast2D

	var was_on_floor = grounded()
	var move = get_movement_input()
	entity.velocity.y  = STICK_TO_GROUND
	if move != 0:
		entity.velocity.x += acceleration * move
		entity.velocity.x = clamp(entity.velocity.x, -move_speed, move_speed)
	else:
		entity.velocity.x *= DECEL_VALUE
	var normal = (ground_checker.get_collision_normal().angle_to(entity.up_direction))
	if normal < 0.02 and normal > -0.02:
		default_move_and_slide()
	else:
		if !ascending_slope():
			move_and_slide_with_slopes(delta)
		else:
			default_move_and_slide()
	if state_machine.transition_if_available(["Fall"]):
		return
	if state_machine.get_current_state() == run_state:
		push_objects()

func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			collision.get_collider().call_deferred("apply_central_impulse", -collision.get_normal() * push ) 

func default_move_and_slide():
	entity.set_max_slides(4)
	entity.set_floor_max_angle(PI/4)
	entity.move_and_slide()
	
func move_and_slide_with_slopes(delta):
	if state_machine.get_current_state().name != "Idle":
		entity.velocity.y += jump_script.get_gravity() 
		entity.velocity.y = clamp(entity.velocity.y, 0, fall_script.maximum_fall_speed)
	entity.set_floor_stop_on_slope_enabled(true)
	entity.set_max_slides(1)
	entity.set_floor_max_angle(PI/2)
	entity.floor_snap_length = 2
	if ground_checker.get_collision_normal() != Vector2.ZERO:
		entity.set_up_direction(ground_checker.get_collision_normal())
	
	
	for i in range(2):
		entity.move_and_slide()
		entity.apply_floor_snap()
	
func calculate_slope(delta, ray: RayCast2D):
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)
	if ground_checker.is_colliding():
		if ray.get_collision_normal():
			var point_a = float(max(ground_checker.get_collision_point().y, entity.position.y) - min (ground_checker.get_collision_point().y, entity.position.y))
			var point_b = float(max(ray.get_collision_point().x, entity.position.x) - min(ray.get_collision_point().x, entity.position.x))
			var slope_angle = rad_to_deg(atan(point_a / point_b))
			var slope_length = sqrt((point_a * point_a) + (point_b + point_b))
			print(str(point_a) + " is the first point.")
			print(str(point_b) + " is the second point.")
			print(str(slope_length) + " is the length.")
			print(str(slope_angle) + " is the angle.")
			entity.set_up_direction(ray.get_collision_normal())
		else:
			entity.set_up_direction(Vector2.UP)
#		entity.velocity -= entity.up_direction * delta

func ascending_slope() -> bool:
	if facing_left():
		if slope_ray_right.is_colliding():
			return false
	else:
		if slope_ray_left.is_colliding():
			return false
	return true 

func exit() -> void:
	entity.velocity.y = 0
	coyote_timer.stop()
	entity.floor_snap_length = 1
	entity.safe_margin = 0.08
	entity.rotation_degrees = 0
	entity.up_direction = Vector2.UP
	slope_ray_left.enabled = false
	slope_ray_right.enabled = false

func conditions_met() -> bool:
	return true
