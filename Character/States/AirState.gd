class_name AirState extends PlayerBaseState

@export var push:int = 100

var remaining_jumps:int = 0
var air_acceleration: int = 20
var max_speed: int = 250

var can_accelerate: bool = true 

func enter(_msg: ={}):
	super.enter()
	entity.set_collision_mask_value(4, true)

func physics_process(_delta):
	if get_movement_input() != 0:
		if facing_left():
			if entity.motion.x > -max_speed:
				entity.motion.x -= air_acceleration
				if entity.motion.x < -max_speed:
					entity.motion.x = -max_speed
		else:
			if entity.motion.x < max_speed:
				entity.motion.x += air_acceleration
				if entity.motion.x > max_speed:
					entity.motion.x = max_speed
	if enter_attack_state():
		return
	
func default_move_and_slide():
	super.default_move_and_slide()
	push_objects()

func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is MoveableObject:
			collision.get_collider().apply_central_impulse(-collision.get_normal() * push )

