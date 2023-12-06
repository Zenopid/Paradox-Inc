extends BaseStrike

func physics_process(delta):
	super.physics_process(delta)
	if frame == 9:
		create_hitbox(14.93, 26, 20,1,180, 4, "Normal", 1,Vector2(16.79, 4.5), Vector2(300, 150),1)
	if frame >= 13:
		return true

