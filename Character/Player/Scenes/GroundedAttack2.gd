extends BaseStrike

func physics_process(delta):
	super.physics_process(delta)
	if frame == 6:
		if facing_left():
			entity.motion.x -= 250 * ( 1 - get_movement_input() )
		else:
			entity.motion.x += 250  * ( 1 + get_movement_input() )
	if frame == 9:
		attack_state.create_hitbox(14.93, 26, 20,1,180, 4, "Normal", 0,Vector2(16.79, 4.5), Vector2(300, 150),1)
	default_move_and_slide()
