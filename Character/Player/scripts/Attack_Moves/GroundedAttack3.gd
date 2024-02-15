extends BaseStrike

func physics_process(delta):
	super.physics_process(delta)
	if frame == 5:
		if entity.sprite.flip_h:
			entity.motion.x -= lunge_distance * ( 1 - get_movement_input() )
		else:
			entity.motion.x += lunge_distance  * ( 1 + get_movement_input() )
	if frame == 9:
		attack_state.create_hitbox(16.785, 21.48, 25, 1, 180, 4, "Normal", 0, Vector2(17.475, 7.049), Vector2(650, 0), 1)
