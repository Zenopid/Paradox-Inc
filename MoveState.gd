class_name MoveState extends BaseState

@export var acceleration = 25
@export var move_speed = 125

@export var coyote_duration: float = 0.4

@export_range(1, 200) var push: int = 50

var coyote_timer: Timer

var push_counter: int = 0
var ground_checker: RayCast2D

@onready var slope_ray_right: RayCast2D
@onready var slope_ray_left: RayCast2D
var test_num: int = 0

func enter(_msg: = {}) -> void:
	super.enter()
	
	slope_ray_left = state_machine.get_raycast("SlopeCheckerLeft")
	slope_ray_right = state_machine.get_raycast("SlopeCheckerRight")
	coyote_timer = state_machine.get_timer("Coyote")
	coyote_timer.wait_time = coyote_duration
	coyote_timer.one_shot = true
	entity.set_collision_mask_value(4, true)
	ground_checker = state_machine.get_raycast("GroundChecker")
	ground_checker.enabled = true

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

func physics_process(delta:float) -> void:
	ground_checker.position = Vector2(entity.position.x, entity.position.y + 13.5)
	slope_ray_left.position = Vector2(entity.position.x - 1, entity.position.y + 13.5)
	slope_ray_right.position = Vector2(entity.position.x + 1, entity.position.y + 13.5)
	if facing_left():
		slope_ray_left.enabled = true
		slope_ray_right.enabled = false
	else:
		slope_ray_left.enabled = false
		slope_ray_right.enabled = true
	var was_on_floor = entity.is_on_floor()
	var move = get_movement_input()
	if move != 0:
		entity.motion.x += acceleration * move
		entity.motion.x = clamp(entity.motion.x, -move_speed, move_speed)
	else:
		entity.motion.x *= 0.85
	var normal = (ground_checker.get_collision_normal().angle_to(entity.up_direction))
	if normal < 0.02 and normal > -0.02:
		default_move_and_slide()
	else:
		move_and_slide_with_slopes(delta)
	if !ground_checker.is_colliding() and coyote_timer.is_stopped():
		if was_on_floor:
			coyote_timer.start()
		if coyote_timer.is_stopped():
			state_machine.transition_to("Fall")
			return
	if state_machine.get_current_state() == state_machine.find_state("Run"):
		push_objects()
	var point = ground_checker.get_collision_point().normalized()
#	print(point)

func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is MoveableObject:
			collision.get_collider().call_deferred("apply_central_impulse", -collision.get_normal() * push ) 

func move_and_slide_with_slopes(delta):
	var jump_script: Jump = state_machine.find_state("Jump")
	var fall_script: Fall = state_machine.find_state("Fall")
	if state_machine.current_state != state_machine.find_state("Idle"):
		entity.motion.y += jump_script.get_gravity() * delta 
		if entity.motion.y > fall_script.maximum_fall_speed:
			entity.motion.y = fall_script.maximum_fall_speed
	entity.set_velocity(entity.motion)
	entity.set_floor_stop_on_slope_enabled(true)
	entity.set_max_slides(1)
	entity.set_floor_max_angle(PI/2)
	entity.floor_snap_length = 5
	entity.set_up_direction(ground_checker.get_collision_normal())
	for i in range(2):
		entity.move_and_slide()
		entity.apply_floor_snap()
#	for i in range(4):
#		calculate_slope(delta, current_slope_ray)
#		entity.move_and_slide()
#		entity.apply_floor_snap()
#	entity.get_wall_normal().normalized().or
##			if entity.motion.y < -acceleration:
##				entity.motion.y = -acceleration
#			var move = get_movement_input()
#			entity.motion.x += ((1 - normal) * acceleration) * (-1 * move)
#			if move < 0:
#				if entity.motion.x < (1 - normal) * move_speed:
#					entity.motion.x = (1 - normal) * move_speed
#			elif move > 0:
#				if entity.motion.x > (1 - normal) * move_speed:
#					entity.motion.x = (1 - normal) * move_speed
#			print("its good cuz its currently " + str(normal))
#		else:
#			print("too steep") 

#	var slides = entity.get_slide_collision_count()
#	if slides:
#		if slides > 1:
#			for i in slides:
#				var touched = entity.get_slide_collision(i) 
#				if entity.is_on_floor() and touched.get_normal().y < 1.0 and entity.motion.x != 0:
#					print("getting normal and stuff")
#					entity.motion.y = touched.get_normal().y


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
#		entity.motion -= entity.up_direction * delta
func exit() -> void:
	state_machine.get_timer("Coyote").stop()
	ground_checker.enabled = false
	entity.floor_snap_length = 1
	entity.safe_margin = 0.08
	entity.rotation_degrees = 0
	entity.up_direction = Vector2.UP
