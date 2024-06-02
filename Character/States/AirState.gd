class_name PlayerAirState extends PlayerBaseState

@export var push:int = 100

var remaining_jumps:int = 0
const air_acceleration: int = 17
const max_speed: int = 250

func enter(_msg: ={}):
	super.enter()
	entity.set_collision_mask_value(4, true)

func physics_process(_delta):

	if get_movement_input() != 0:
		if facing_left():
			if entity.velocity.x > -max_speed:
				entity.velocity.x -= air_acceleration
				if entity.velocity.x < -max_speed:
					entity.velocity.x = -max_speed
		else:
			if entity.velocity.x < max_speed:
				entity.velocity.x += air_acceleration
				if entity.velocity.x > max_speed:
					entity.velocity.x = max_speed
		
func default_move_and_slide():
	entity.move_and_slide()
	push_objects()

func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			collision.get_collider().apply_central_impulse(-collision.get_normal() * push )

