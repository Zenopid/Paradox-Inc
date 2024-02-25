extends BaseStrike

@export var damage: int = 20

func physics_process(delta):
	super.physics_process(delta)
	if frame == 6:
		if entity.sprite.flip_h:
			entity.motion.x -= lunge_distance * ( 1 - get_movement_input() )
		else:
			entity.motion.x += lunge_distance  * ( 1 + get_movement_input() )
	if frame == 9:
		attack_state.create_hitbox(14.93, 26, damage,1,180, 4, "Normal", 0,Vector2(16.79, 4.5), Vector2(300, 150),1)

