extends BaseStrike

func physics_process(delta):
	super.physics_process(delta)
	if frame == 19:
		attack_state.create_hitbox(31.745, 42.426, 15, 1, 180, 3, "Normal", 1, Vector2(25.672, 4.423), Vector2(600, -100))



