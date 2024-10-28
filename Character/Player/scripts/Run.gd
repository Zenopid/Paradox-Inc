extends PlayerMoveState

func physics_process(delta:float):
	super.physics_process(delta)
	push_objects()
	
func push_objects():
	for i in entity.get_slide_collision_count():
		var collision = entity.get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			collision.get_collider().call_deferred("apply_central_impulse", -collision.get_normal() * push ) 

func conditions_met() -> bool:
	return get_movement_input() != 0 and grounded()
