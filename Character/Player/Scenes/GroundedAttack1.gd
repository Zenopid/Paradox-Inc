extends BaseStrike

func physics_process(delta):
	super.physics_process(delta)
	if frame == 4:
		if facing_left():
			entity.motion.x -= 150 * ( 1 - get_movement_input())
		else:
			entity.motion.x += 150 * ( 1 + get_movement_input() )
	if frame == 7:
		attack_state.create_hitbox(15.75, 36.5, 15, 1, 360, 4, "Normal", 0, Vector2(15,-0.75), Vector2(450,-100), 1)
	if frame == 11:
		attack_state.create_hitbox(21, 13.25, 10, 1, 90, 2, "Normal", 0, Vector2(6.5,-12), Vector2(200, -150), 1)
	default_move_and_slide()
