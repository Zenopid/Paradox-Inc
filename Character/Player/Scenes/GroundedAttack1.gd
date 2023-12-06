extends BaseStrike

func physics_process(delta):
	super.physics_process(delta)
	if frame == 7:
		create_hitbox(15.75, 36.5, 15, 1, 180,4, "Normal", 0, Vector2(15,- 0.75), Vector2(350, -50), 1)
	if frame == 11:
		create_hitbox(21, 13.25, 10, 1, 90, 2, "Normal", 0, Vector2(6.5,-12), Vector2(200, -100), 1)
	if frame >= 13:
		return true
		
